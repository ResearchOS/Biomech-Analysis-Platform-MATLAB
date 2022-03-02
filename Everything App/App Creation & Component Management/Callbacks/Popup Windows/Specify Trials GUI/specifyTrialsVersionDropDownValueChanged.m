function []=specifyTrialsVersionDropDownValueChanged(src,event)

%% PURPOSE: SWITCH ALL SPECIFY TRIALS CRITERIA SHOWING BASED ON PRESET CONFIGURATIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
specifyTrialsPath=getappdata(fig,'allProjectsSpecifyTrialsPath');

if exist(specifyTrialsPath,'file')~=2
    return; % If the text file does not exist, don't do anything.
end

value=handles.Top.specifyTrialsDropDown.Value;

pguiFig=evalin('base','gui;');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=getappdata(pguiFig,'projectName');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

specifyTrialsPath=getappdata(fig,'allProjectsSpecifyTrialsPath');
guiLocation=getappdata(fig,'guiLocation');

assert(exist(specifyTrialsPath,'file')==2);

% Here, the .txt file exists. Check if the current project exists.
text=readSpecifyTrials(getappdata(pguiFig,'everythingPath'));
projectList=getAllProjectNames(text);

assert(ismember(projectName,projectList));

numLines=length(text);

% Current project exists
currProj=0;
for i=1:numLines
    projLine=['Project Name: ' getappdata(pguiFig,'projectName')];

    if length(text{i})>=length(projLine) && isequal(text{i}(1:length(projLine)),projLine)
        currProj=1;
        continue;
    end

    if currProj~=1
        continue;
    end

    splitLine=strsplit(text{i},slash);
    vName=strsplit(splitLine{end},['_' projectName]);
    vName=vName{1}; % Isolate the version name.

    if isequal(value,vName)
        colonIdx=strfind(text{i},':');
        charStartIdx=colonIdx(1)+2;
        specifyTrialsMPath=text{i}(charStartIdx:end);
        break;

    end

end

if exist(specifyTrialsMPath,'file')~=2 % If the file was deleted, re-create it with defaults.
    assignin('base','vNameToAddSpecifyTrials',vName);
    assignin('base','ignoreInputToAddSpecifyTrials',1);
    specifyTrialsDropDownAddButtonPushed(fig);
    evalin('base','clear vNameToAddSpecifyTrials ignoreInputToAddSpecifyTrials');
end

[folder,name]=fileparts(specifyTrialsMPath);
% [folder,name]=fileparts(a);
currCD=cd(folder);

if exist(specifyTrialsMPath,'file')~=2
    warning(['Please remove this version. The specify trials file was deleted: ' specifyTrialsMPath]);
    return;
end

inclStruct=feval(name);
setappdata(fig,'inclStruct',inclStruct);
setappdata(fig,'specifyTrialsMPath',specifyTrialsMPath);
cd(currCD);

% Parse the inclStruct to populate the GUI.

currSelectedTab=handles.Top.includeExcludeTabGroup.SelectedTab;
for inclExcl=1:2

    switch inclExcl
        case 1
            type='Include';  
            currTab=handles.Top.includeTab;    
        case 2
            type='Exclude';
            currTab=handles.Top.excludeTab;    
    end    

    currCondDropDown=handles.(type).conditionDropDown;

    if ~isstruct(inclStruct) || ~isfield(inclStruct,'Include')
        disp('No trials to include');
        condNames={'Add Condition Name'};
        currCondDropDown.Items=condNames;
        currCondDropDown.Value=condNames{1};

        conditionNameDropDownValueChanged(currCondDropDown); % Propagate the changes
        return;
    end

    if ~isfield(inclStruct,type)
        continue;
    end

    currStruct=inclStruct.(type);

    condNames=cell(length(currStruct.Condition),1);

    for condNum=1:length(currStruct.Condition)
        condNames{condNum}=currStruct.Condition(condNum).Name;        
    end

    currCondDropDown.Items=condNames;
    currCondDropDown.Value=condNames{1};

    handles.Top.includeExcludeTabGroup.SelectedTab=currTab;

    conditionNameDropDownValueChanged(currCondDropDown); % Propagate the changes

end

handles.Top.includeExcludeTabGroup.SelectedTab=currSelectedTab;

% If it was present on another specifyTrials version, remove it.
allFixed=[0 0];
for i=1:length(text)

    guiLocIdx=strfind(text{i},guiLocation);
    if ~isempty(guiLocIdx)
        colonIdx=strfind(text{i},':');
        colonIdx=colonIdx(1); % First colon
        beforeColonSplit=strsplit(text{i}(1:colonIdx-1),', ');
        count=0;
        newBeforeColon='';
        for j=1:length(beforeColonSplit)

            if isequal(beforeColonSplit{j},guiLocation)
                continue;
            end

            count=count+1;

            if count==1
                newBeforeColon=beforeColonSplit{j};
            else
                newBeforeColon=[newBeforeColon ', ' beforeColonSplit{j}];
            end            

        end 

        text{i}=[newBeforeColon text{i}(colonIdx:end)]; 
        allFixed(1)=1;
    end

    if ~isempty(strfind(text{i},specifyTrialsMPath)) % This is the correct specify trials version.
        colonIdx=strfind(text{i},':');
        colonIdx=colonIdx(1);
        if isequal(colonIdx,1)
            text{i}=[guiLocation text{i}];
        else
            text{i}=[guiLocation ', ' text{i}];
        end
        allFixed(2)=1;
    end

    if all(allFixed)
        break;
    end

end

fid=fopen(specifyTrialsPath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);