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
% guiLocation=getappdata(fig,'guiLocation');

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

assert(exist(specifyTrialsMPath,'file')==2);

a='C:\Users\Mitchell\Desktop\Matlab Code\GitRepos\Spr21-TWW-Biomechanics\Import_Spr21TWWBiomechanics\Specify Trials\specifyTrials_Import1.m';

% [folder,name]=fileparts(specifyTrialsMPath);
[folder,name]=fileparts(a);
currCD=cd(folder);
inclStruct=feval(name);
setappdata(fig,'inclStruct',inclStruct);
cd(currCD);

if ~isfield(inclStruct,'Include')
    disp('No trials to include');
    return;
end

% Parse the inclStruct to populate the GUI.
for inclExcl=1:2

    switch inclExcl
        case 1
            type='Include';            
        case 2
            type='Exclude';
    end

    if ~isfield(inclStruct,type)
        continue;
    end

    currTab=handles.(type);
    currStruct=inclStruct.(type);

    currCondDropDown=currTab.conditionDropDown;

    condNames=cell(length(currStruct.Condition),1);

    for condNum=1:length(currStruct.Condition)
        condNames{condNum}=currStruct.Condition(condNum).Name;        
    end

    currCondDropDown.Items=condNames;
    currCondDropDown.Value=condNames{1};

    conditionNameDropDownValueChanged(currCondDropDown,type); % Propagate the changes

end