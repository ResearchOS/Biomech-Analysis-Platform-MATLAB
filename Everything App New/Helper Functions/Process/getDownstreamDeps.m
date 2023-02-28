function [allList]=getDownstreamDeps(startProcessOrig,startVariableOrig,allList,startProcessNew,startVariableNew)

%% PURPOSE: GET THE LIST OF ALL VARIABLES & PROCESS FUNCTIONS THAT DEPEND ON THE SPECIFIED PROCESS

if exist('allList','var')~=1 || isempty(allList)
    allList={};
end

startProcessPath=getClassFilePath(startProcessOrig,'Process');
startProcessStructOrig=loadJSON(startProcessPath);

startVariablePath=getClassFilePath(startVariableOrig,'Variable');
startVariableStructOrig=loadJSON(startVariablePath);

% Check that this variable is an output of the process function
assert(ismember(startVariableStructOrig.Text,startProcessStructOrig.ForwardLinks_Variable));
assert(ismember(startProcessStructOrig.Text,startVariableStructOrig.BackwardLinks_Process));

%% Get the process functions that use this variable.
nextProcess=startVariableStructOrig.ForwardLinks_Process;
st=dbstack;
% rowNum=0;
for i=1:length(nextProcess)
    allList=[allList; {startVariableStructOrig.Text nextProcess{i}}];

    firstColIdx=ismember(allList(:,1),allList{end,1});
    secondColIdx=ismember(allList(:,2),allList{end,2});

    if sum(firstColIdx & secondColIdx)>1
        allList=allList(1:end-1,:);
        continue;
    end

    disp(['Row: ' num2str(size(allList,1)) ' Level: ' num2str(length({st.name})) ' Process ' num2str(i) ' Of ' num2str(length(nextProcess))]);

    nextProcessPath=getClassFilePath(nextProcess{i},'Process');
    nextProcessStruct=loadJSON(nextProcessPath);
    nextVars=nextProcessStruct.ForwardLinks_Variable;
    for j=1:length(nextVars)
        allList=getDownstreamDeps(nextProcess{i},nextVars{j},allList);
    end
end

st=dbstack;
if length({st.name})>=2 % || ~isequal(st(2).name,mfilename)
    return;
end

%% Create a new list with new objects in it
newList=allList;
uniqueVars=unique(allList(:,1),'stable');
for i=1:length(uniqueVars)

    currVar=uniqueVars{i,1};
    currVarRows=find(ismember(allList(:,1),currVar)==1);

    [varName,varID,varPSID]=deText(currVar);
    newVarText=[varName '_' varID]; % Exclude variable prefix
    newVarPSID=createPSID(newVarText,'Variable');
    prevVarText=[newVarText '_'  varPSID];
    newVarText=[newVarText '_' newVarPSID];

    newList(currVarRows,1)=deal({newVarText});

    for j=1:length(currVarRows)

        currProcess=allList{currVarRows(j),2};
        [processName,processID,processPSID]=deText(currProcess);
        newProcessText=[processName '_' processID];
        newProcessPSID=createPSID(newProcessText,'Process');
        prevProcessText=[newProcessText '_' processPSID];
        newProcessText=[newProcessText '_' newProcessPSID];

        newList{currVarRows(j),2}=newProcessText;

    end

end

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
processGroupPath=getClassFilePath(Current_ProcessGroup_Name);
processGroupStruct=loadJSON(processGroupPath);

%% Copy the previous objects to the new ones.
uniqueNewVars=unique(newList(:,1),'stable');
for i=1:length(uniqueNewVars)

    currVar=uniqueNewVars{i,1};
    currVarRows=find(ismember(newList(:,1),currVar)==1);

    % Omit the 'Variable_' prefix
    prevVarText=allList{currVarRows(1),1};
    newVarText=newList{currVarRows(1),1};

    % Copy the previous objects to the new objects.
    prevPath=getClassFilePath(prevVarText,'Variable');
    newVariablePath=getClassFilePath(newVarText,'Variable');
    copyfile(prevPath,newVariablePath);

    % Modify the links that should be modified & retained, delete the rest
    newVarStruct=loadJSON(newVariablePath);

    for j=1:length(currVarRows)

        prevProcessText=allList{currVarRows(j),2};
        newProcessText=newList{currVarRows(j),2};

        % Copy the previous objects to the new objects.
        prevPath=getClassFilePath(prevProcessText,'Process');
        newProcessPath=getClassFilePath(newProcessText,'Process');
        copyfile(prevPath,newProcessPath);

        % Modify the links that should be modified & retained, delete the rest
        newProcessStruct=loadJSON(newProcessPath);

        %% Modify Input variables
        for k=1:length(newProcessStruct.InputVariables)
            getArgVars=newProcessStruct.InputVariables{k};
            if length(getArgVars)<2
                continue;
            end
            varIdx=[false; ismember(getArgVars(2:end),prevVarText)];
            newProcessStruct.InputVariables{k}{varIdx}=newVarText;
        end

        % Modify links
        % Back links from process struct to input variables
        backLinksIdx=ismember(newProcessStruct.BackwardLinks_Variable,prevVarText);
        newProcessStruct.BackwardLinks_Variable{backLinksIdx}=newVarText;

        % Forward links from input variables to process struct
        fwdLinksIdx=ismember(newVarStruct.ForwardLinks_Process,prevProcessText);
        newVarStruct.ForwardLinks_Process{fwdLinksIdx}=newProcessText;

        %% Modify Output variables
        prevOutputVars=newProcessStruct.ForwardLinks_Variable;
        for k=1:length(prevOutputVars)
            prevOutputVar=prevOutputVars{k};
            for l=1:length(newProcessStruct.OutputVariables)
                setArgVars=newProcessStruct.OutputVariables{l};
                if length(setArgVars)<2
                    continue;
                end
                varIdx=[false; ismember(setArgVars(2:end),prevOutputVar)];
                prevOutputVarIdxNum=find(ismember(allList(:,1),prevOutputVar)==1); % Empty if this output variable was not an input to anywhere
                if ~isempty(prevOutputVarIdxNum)
                    newProcessStruct.OutputVariables{l}{varIdx}=newList{prevOutputVarIdxNum(1),1};
                    newVarTextList{k,1}=newList{prevOutputVarIdxNum(1),1};
                else
                    % Create new output variable name here
                    [varName,varID,varPSID]=deText(prevOutputVar);
                    newVarText=[varName '_' varID]; % Exclude variable prefix
                    newVarPSID=createPSID(newVarText,'Variable');
                    prevVarText=[newVarText '_'  varPSID];
                    newVarText=[newVarText '_' newVarPSID];

                    % Copy the previous objects to the new objects.
                    prevPath=getClassFilePath(prevVarText,'Variable');
                    newPath=getClassFilePath(newVarText,'Variable');
                    copyfile(prevPath,newPath);

                    % Replace the process name in the variable
                    newVarStructOutput=loadJSON(newPath);
                    processIdx=ismember(newVarStructOutput.BackwardLinks_Process,prevProcessText);
                    newVarStructOutput.BackwardLinks_Process{processIdx}=newProcessText;

                    newProcessStruct.OutputVariables{l}{varIdx}=newVarText;
                    newVarTextList{k,1}=newVarText;

                    writeJSON(newPath,newVarStructOutput);

                end

            end

        end

        newProcessStruct.ForwardLinks_Variable=newVarTextList;

        % Add new process group versions to the process
        processGroups=newProcessStruct.ForwardLinks_ProcessGroup;
        for groupNum=1:length(processGroups)

            groupName=processGroups{groupNum};
            [name,id,psid]=deText(groupName);
            groupNamePI=[name '_' id];
            psid=createPSID(groupNamePI,'ProcessGroup');
            groupName=[groupNamePI '_' psid];
            newProcessStruct.ForwardLinks_ProcessGroup=[newProcessStruct.ForwardLinks_ProcessGroup; groupName];

        end

        newProcessStruct.ForwardLinks_ProcessGroup(ismember(newProcessStruct.ForwardLinks_ProcessGroup,processGroups))=[];

        writeJSON(newProcessPath,newProcessStruct);

        % Add the new process to the process group.
        prevProcessIdx=ismember(processGroupStruct.BackwardLinks_Process,prevProcessText);
        processGroupStruct.BackwardLinks_Process(prevProcessIdx)=[];
        processGroupStruct.BackwardLinks_Process=[processGroupStruct.BackwardLinks_Process; newProcessText];

    end

    writeJSON(newVariablePath,newVarStruct);

end

writeJSON(processGroupPath,processGroupStruct);