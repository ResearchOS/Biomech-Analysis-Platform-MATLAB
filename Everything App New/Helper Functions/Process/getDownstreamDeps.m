function [allListIn,allListOut]=getDownstreamDeps(prevProcessOrig,newProcessOrig,prevVarsOrig,allListIn,allListOut)

%% PURPOSE: CREATE NEW VERSIONS OF ALL VARIABLES & PROCESS FUNCTIONS THAT DEPEND ON THE SPECIFIED PROCESS

if exist('allListIn','var')~=1 || isempty(allListIn)
    allListIn={};
    allListOut={};
end

% Ensures that either new input vars are going to the same process, or a new process with the same input vars. Not both simultaneously!
if ~isempty(newProcessOrig)
    assert(isempty(prevVarsOrig)); % Top level only
    newProcess=true;
elseif ~isempty(prevVarsOrig)
    assert(isempty(newProcessOrig)); % Top level or lower level
    newProcess=false;
end

startProcessPath=getClassFilePath(prevProcessOrig,'Process');
startProcessStructOrig=loadJSON(startProcessPath);

if newProcess % Switching to a new PI process
    
    % Check that the PI & PS JSON exists! Create it if not.
    [name,id,psid]=deText(newProcessOrig);
    if isempty(id)
        error('Need to specify PI ID at least, so we know which Process we are dealing with!');
    end
    piProcess=[name '_' id];
    piPath=getClassFilePath(piProcess,'Process');
    if exist(piPath,'file')~=2
        startProcessStructNewPI=createProcessStruct(name,id);
    else
        startProcessStructNewPI=loadJSON(piPath);
    end
    if ~isempty(psid)
        psProcess=[name '_' id '_' psid];
        psPath=getClassFilePath(psProcess,'Process');
    end
    if exist(psPath,'file')~=2
        if isempty(psid)
            startProcessStructNew=createProcessStruct_PS(startProcessStructNewPI);
        else
            startProcessStructNew=createProcessStruct_PS(startProcessStructNewPI,psid);
        end
    else
        startProcessStructNew=loadJSON(psPath);
    end
    newProcessOrig=startProcessStructNew.Text; % To replace the process name with down the line

    startVarText=startProcessStructOrig.BackwardLinks_Variable{1}; % An arbitrary input variable to the starting process function.
    startVarPath=getClassFilePath(startVarText,'Variable');
    startVarStruct=loadJSON(startVarPath);

else
    startVarText=prevVarsOrig{1};
    startVarPath=getClassFilePath(startVarText,'Variable');
    startVarStruct=loadJSON(startVarPath);
end

%% Get the process functions that use this variable.
st=dbstack;
nextProcess=startVarStruct.ForwardLinks_Process;
for i=1:length(nextProcess)
    allListIn=[allListIn; {startVarText nextProcess{i}}];

    %% Check that this is not a repeat.
    firstColIdx=ismember(allListIn(:,1),allListIn{end,1});
    secondColIdx=ismember(allListIn(:,2),allListIn{end,2});

    if sum(firstColIdx & secondColIdx)>1
        allListIn=allListIn(1:end-1,:);
        continue;
    end

    disp(['Row: ' num2str(size(allListIn,1)) ' Level: ' num2str(length({st.name})) ' Process ' num2str(i) ' Of ' num2str(length(nextProcess))]);

    nextProcessPath=getClassFilePath(nextProcess{i},'Process');
    nextProcessStruct=loadJSON(nextProcessPath);
    if ~isfield(nextProcessStruct,'ForwardLinks_Variable')
        continue;
    end
    nextVars=nextProcessStruct.ForwardLinks_Variable; % Get all of this process' output variables.
    for j=1:length(nextVars)
        allListOut=[allListOut; {nextProcess{i} nextVars{j}}];
        firstColIdx=ismember(allListOut(:,1),allListOut{end,1});
        secondColIdx=ismember(allListOut(:,2),allListOut{end,2});

        if sum(firstColIdx & secondColIdx)>1
            allListOut=allListOut(1:end-1,:);
            continue;
        end
        [allListIn,allListOut]=getDownstreamDeps(nextProcessStruct.Text,[],nextVars(j),allListIn,allListOut);
    end
end

st=dbstack;
stNames={st.name};
if sum(ismember(stNames,mfilename))>1
    return;
end

%% Create a new list with new objects in it
initVarIdx=ismember(allListIn(:,1),allListIn{1,1}); % The first input variable is to be removed, it just kicks things off.
allListIn(initVarIdx,:)=[];
prevVars=unique([allListIn(:,1); allListOut(:,2)],'stable'); % Aggregate all of the variables
prevProcesses=unique([allListIn(:,2); allListOut(:,1)],'stable'); % Aggregate all of the processes

newVars=cell(size(prevVars));
newProcesses=cell(size(prevProcesses));

%% Create new variable names
for i=1:length(newVars)

    currVar=prevVars{i};
    [varName,varID,varPSID]=deText(currVar);
    newVarText=[varName '_' varID]; % Exclude variable prefix
    newVarPSID=createPSID(newVarText,'Variable');
    prevVarText=[newVarText '_'  varPSID];
    newVarText=[newVarText '_' newVarPSID];

    newVars{i}=newVarText;

end

%% Create new process names
for i=1:length(newProcesses)

    currProcess=prevProcesses{i};
    [processName,processID,processPSID]=deText(currProcess);
    newProcessText=[processName '_' processID]; % Exclude variable prefix
    newProcessPSID=createPSID(newProcessText,'Process');
    prevProcessText=[newProcessText '_'  processPSID];
    newProcessText=[newProcessText '_' newProcessPSID];

    newProcesses{i}=newProcessText;

end

% If switching to a new PI process, swap out that name here.
if newProcess
    newProcessIdx=ismember(prevProcesses,prevProcessOrig);
    newProcesses{newProcessIdx}=newProcessOrig;
end

%% Get the list of process groups
prevProcessGroups={};
for i=1:size(prevProcesses,1)

    currProcess=prevProcesses{i};
    processPath=getClassFilePath(currProcess,'Process');
    processStruct=loadJSON(processPath);
    if ~isfield(processStruct,'ForwardLinks_ProcessGroup')
        continue;
    end

    prevProcessGroups=[prevProcessGroups; processStruct.ForwardLinks_ProcessGroup];

end

%% Create new process groups
prevProcessGroups=unique(prevProcessGroups,'stable');
newProcessGroups=cell(size(prevProcessGroups));
for i=1:length(prevProcessGroups)

    [name,id,psid]=deText(prevProcessGroups{i});
    piGroup=[name '_' id];
    psid=createPSID(piGroup,'ProcessGroup');
    newGroup=[piGroup '_' psid];
    newProcessGroups{i}=newGroup;

end

for i=1:length(prevProcessGroups)

    prevGroupPath=getClassFilePath(prevProcessGroups{i},'ProcessGroup');
    newGroupPath=getClassFilePath(newProcessGroups{i},'ProcessGroup');

    copyJSON(prevGroupPath,newGroupPath);

    % Update the process list
    newGroupStruct=loadJSON(newGroupPath);
    names=newGroupStruct.ExecutionListNames;
    [~,~,namesIdx]=intersect(prevProcesses,names);
    [~,~,processesIdx]=intersect(names,prevProcesses);
    newNames=names;
    newNames(namesIdx)=newProcesses(processesIdx);
    assert(all(ismember(newGroupStruct.ExecutionListTypes(namesIdx),'Process')));

    % Update the process groups in this current group
    [~,~,groupsNamesIdx]=intersect(prevProcessGroups,names);
    [~,~,processGroupsIdx]=intersect(names,prevProcessGroups);
    newNames(groupsNamesIdx)=newProcessGroups(processGroupsIdx);
    assert(all(ismember(newGroupStruct.ExecutionListTypes(groupsNamesIdx),'ProcessGroup')));

    % Update the backwardlinks_process (there are no backwardlinks_process)
    if isfield(newGroupStruct,'BackwardLinks_Process') && ~isempty(newGroupStruct.BackwardLinks_Process)
        backLinks=newGroupStruct.BackwardLinks_Process;
        [~,~,backLinksIdx]=intersect(prevProcesses,backLinks);
        [~,~,processesIdx]=intersect(backLinks,prevProcesses);
        backLinks(backLinksIdx)=newProcesses(processesIdx);
        newGroupStruct.BackwardLinks_Process=backLinks;
    end

    % Update the forwardlinks_processgroup
    if isfield(newGroupStruct,'ForwardLinks_ProcessGroup') && ~isempty(newGroupStruct.ForwardLinks_ProcessGroup)
        fwdLinks=newGroupStruct.ForwardLinks_ProcessGroup;
        [~,~,fwdLinksIdx]=intersect(prevProcessGroups,fwdLinks);
        [~,~,processGroupsIdx]=intersect(fwdLinks,prevProcessGroups);
        fwdLinks(fwdLinksIdx)=newProcessGroups(processGroupsIdx);
        newGroupStruct.ForwardLinks_ProcessGroup=fwdLinks;
    end

    % Update the backwardlinks_processgroup
    if isfield(newGroupStruct,'BackwardLinks_ProcessGroup') && ~isempty(newGroupStruct.BackwardLinks_ProcessGroup)
        backLinksGroup=newGroupStruct.BackwardLinks_ProcessGroup;
        [~,~,backLinksGroupIdx]=intersect(prevProcessGroups,backLinksGroup);
        [~,~,processGroupsIdx]=intersect(backLinksGroup,prevProcessGroups);
        backLinksGroup(backLinksGroupIdx)=newProcessGroups(processGroupsIdx);
        newGroupStruct.BackwardLinks_ProcessGroup=backLinksGroup;
    end

    % Save the group
    newGroupStruct.ExecutionListNames=newNames;
    writeJSON(newGroupPath,newGroupStruct);

end

%% Create new variables
for i=1:length(prevVars)

    prevVarPath=getClassFilePath(prevVars{i},'Variable');
    newVarPath=getClassFilePath(newVars{i},'Variable');

    copyJSON(prevVarPath,newVarPath);

    % Update the linked processes
    newVarStruct=loadJSON(newVarPath);

    if isfield(newVarStruct,'ForwardLinks_Process') && ~isempty(newVarStruct.ForwardLinks_Process)
        fwdLinks=newVarStruct.ForwardLinks_Process;
        [~,~,fwdLinksIdx]=intersect(prevProcesses,fwdLinks);
        [~,~,processesIdx]=intersect(fwdLinks,prevProcesses);
        newFwdLinks=fwdLinks;
        newFwdLinks(fwdLinksIdx)=newProcesses(processesIdx);
        newVarStruct.ForwardLinks_Process=newFwdLinks;
    end

    if isfield(newVarStruct,'BackwardLinks_Process') && ~isempty(newVarStruct.BackwardLinks_Process)
        backLinks=newVarStruct.BackwardLinks_Process;
        [~,~,backLinksIdx]=intersect(prevProcesses,backLinks);
        [~,~,processesIdx]=intersect(backLinks,prevProcesses);
        newBackLinks=backLinks;
        newBackLinks(backLinksIdx)=newProcesses(processesIdx);
        newVarStruct.BackwardLinks_Process=newBackLinks;
    end

    % Remove links to plot components
    fields=fieldnames(newVarStruct);
    linksFields=fields(contains(fields,'Links_'));
    linksFields=linksFields(~ismember(linksFields,{'ForwardLinks_Process','BackwardLinks_Process'}));

    for j=1:length(linksFields)
        newVarStruct=rmfield(newVarStruct,linksFields{j});
    end

    writeJSON(newVarPath,newVarStruct);

end

%% Create new processes
for i=1:length(prevProcesses)

    prevProcessPath=getClassFilePath(prevProcesses{i},'Process');
    newProcessPath=getClassFilePath(newProcesses{i},'Process');

    copyJSON(prevProcessPath,newProcessPath);

    % Update the linked processes
    newProcessStruct=loadJSON(newProcessPath);

    if isfield(newProcessStruct,'ForwardLinks_Variable') && ~isempty(newProcessStruct.ForwardLinks_Variable)
        fwdLinks=newProcessStruct.ForwardLinks_Variable;
        [~,~,fwdLinksIdx]=intersect(prevVars,fwdLinks);
        [~,~,varsIdx]=intersect(fwdLinks,prevVars);
        newFwdLinks=fwdLinks;
        newFwdLinks(fwdLinksIdx)=newVars(varsIdx);
        newProcessStruct.ForwardLinks_Variable=newFwdLinks;
    end

    if isfield(newProcessStruct,'BackwardLinks_Variable') && ~isempty(newProcessStruct.BackwardLinks_Variable)
        backLinks=newProcessStruct.BackwardLinks_Variable;
        [~,~,backLinksIdx]=intersect(prevVars,backLinks);
        [~,~,varsIdx]=intersect(backLinks,prevVars);
        newBackLinks=backLinks;
        newBackLinks(backLinksIdx)=newVars(varsIdx);
        newProcessStruct.BackwardLinks_Variable=newBackLinks;
    end

    % Forwardlinks_processgroup
    if isfield(newProcessStruct,'ForwardLinks_ProcessGroup') && ~isempty(newProcessStruct.ForwardLinks_ProcessGroup)
        fwdLinksGroup=newProcessStruct.ForwardLinks_ProcessGroup;
        [~,~,fwdLinksGroupIdx]=intersect(prevProcessGroups,fwdLinksGroup);
        [~,~,processGroupsIdx]=intersect(fwdLinksGroup,prevProcessGroups);
        newFwdLinksGroup=fwdLinksGroup;
        newFwdLinksGroup(fwdLinksGroupIdx)=newProcessGroups(processGroupsIdx);
        newProcessStruct.ForwardLinks_ProcessGroup=newFwdLinksGroup;
    end

    % Update the input variables
    if isfield(newProcessStruct,'InputVariables') && ~isempty(newProcessStruct.InputVariables)
        inputVars=newProcessStruct.InputVariables;
        for j=1:length(inputVars)
            currVars=inputVars{j};
            idx=currVars{1};
            if length(currVars)<=1
                inputVars{j}=currVars;
                continue;
            end
            currVars=currVars(2:end);
            [~,~,currVarsIdx]=intersect(prevVars,currVars);
            [~,~,prevVarsIdx]=intersect(currVars,prevVars);
            newCurrVars=currVars;
            newCurrVars(currVarsIdx)=newVars(prevVarsIdx);
            inputVars{j}=[{idx}; newCurrVars];
        end
        newProcessStruct.InputVariables=inputVars;
    end

    % Update the output variables
    if isfield(newProcessStruct,'OutputVariables') && ~isempty(newProcessStruct.OutputVariables)
        outputVars=newProcessStruct.OutputVariables;
        for j=1:length(outputVars)
            currVars=outputVars{j};
            idx=currVars{1};
            if length(currVars)<=1
                outputVars{j}=currVars;
                continue;
            end
            currVars=currVars(2:end);
            [~,~,currVarsIdx]=intersect(prevVars,currVars);
            [~,~,prevVarsIdx]=intersect(currVars,prevVars);
            newCurrVars=currVars;
            newCurrVars(currVarsIdx)=newVars(prevVarsIdx);
            outputVars{j}=[{idx}; newCurrVars];
        end
        newProcessStruct.OutputVariables=outputVars;
    end

%     if newProcess && isequal(newProcessStruct.Text,newProcessOrig)
%         newProcessStruct.OutputVariables={};
%         newProcessStruct.InputVariables={};
%     end

    writeJSON(newProcessPath,newProcessStruct);

end