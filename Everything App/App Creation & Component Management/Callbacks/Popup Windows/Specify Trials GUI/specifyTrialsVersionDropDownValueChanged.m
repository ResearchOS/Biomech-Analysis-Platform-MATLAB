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
        charStartIdx=strfind(text{i},':')+2;
        if isempty(charStartIdx) || charStartIdx(1)<=5
            charStartIdx=1;
        else
            charStartIdx=charStartIdx(1);     
        end
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
cd(currCD);

if ~isfield(inclStruct,'Include')
    disp('No trials to include');
    return;
end

logVar=load(getappdata(pguiFig,'LogsheetMatPath'));
fldName=fieldnames(logVar);
assert(length(fldName)==1);
logVar=logVar.(fldName{1});
headerRow=logVar(1,:);
numCols=length(headerRow);
logicOptions={'is','is not','contains','does not contain','is empty','is not empty','ignore'};

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

        for i=1:2 % Logsheet or structure

            switch i
                case 1
                    type2='Logsheet';
                    currSubTab=currTab.LogTab;
                case 2
                    type2='Structure';
                    currSubTab=currTab.StructTab;
            end

            if ~isfield(currStruct.Condition,type2) || (isfield(currStruct.Condition,type2) && isempty(currStruct.Condition(condNum).(type2)))
                continue; % The logsheet or structure criteria does not exist for this condition.
            end

            currType2Struct=currStruct.Condition(condNum).(type2);

            % Delete items
            switch i
                case 1
                    if ~isempty(getappdata(fig,'logsheetEntryHandles'))
                        currHandles=getappdata(fig,'logsheetEntryHandles');
                    else
                        currHandles='';
                    end
                case 2
                    if ~isempty(getappdata(fig,'structEntryHandles'))
                        currHandles=getappdata(fig,'structEntryHandles');
                    else
                        currHandles='';
                    end
            end

            for j=1:length(currHandles)
                delete(currHandles.Labels{j});
                delete(currHandles.DropDown{j});
                delete(currHandles.TextField{j});
            end

            % Re-populate items
            for j=1:numCols
                entryHandles.ColName{j}=headerRow{j};
                entryHandles.Labels{j}=uilabel(currSubTab,'Text',headerRow{j});
                currLogDropDown=uidropdown(currSubTab,'Items',logicOptions,'Value','ignore','ValueChangedFcn',@(currLogDropDown,event) logicDropDownValueChanged(currLogDropDown));
                entryHandles.DropDown{j}=currLogDropDown;
                currLogEditField=uieditfield(currSubTab,'text','Value','','ValueChangedFcn',@(currLogEditField, event) logsheetEditFieldValueChanged(currLogEditField));
                entryHandles.TextField{j}=currLogEditField;
            end

            % Need to position them, and determine whether I need the up and down arrows.    
            figSize=fig.Position(3:4);
            figMult=[figSize figSize(1)];
            buttonsFixed=0;
            for j=1:numCols

                if 0.6-(j-1)*0.1<=0
                    entryHandles.Labels{j}.Visible='off';
                    entryHandles.DropDown{j}.Visible='off';
                    entryHandles.TextField{j}.Visible='off';
                    if buttonsFixed==0
                        % Turn down arrow visibility on.
                        handles.Include.DownArrowButton.Visible='on';
                        handles.Include.UpArrowButton.Visible='off';
                    end
                    continue;
                end
                
                entryHandles.Labels{j}.Position=[[0.02 0.6-(j-1)*0.1 0.2].*figMult round(1.67*12)];                
                entryHandles.DropDown{j}.Position=[[0.25 0.6-(j-1)*0.1 0.2].*figMult round(1.67*12)];
                entryHandles.TextField{j}.Position=[[0.5 0.6-(j-1)*0.1 0.4].*figMult round(1.67*12)];
                
            end

            for j=1:length(currType2Struct)
                currName=currType2Struct.Name;
                currValue=currType2Struct.Value;
                currLogic=currType2Struct.Logic; % is, is not, contains, does not contain, is empty, is not empty, ignore

                if isequal(currLogic,'ignore')
                    continue;
                end

                for k=1:length(entryHandles.ColName)
                    if isequal(currName,entryHandles.ColName{k})
                        entryHandles.DropDown{j}.Value=currLogic;
                        entryHandles.TextField{j}.Value=currValue;
                    end
                end

            end

            switch i
                case 1
                    setappdata(fig,'logsheetEntryHandles',entryHandles);
                case 2
                    setappdata(fig,'structEntryHandles',entryHandles);
            end

        end


    end

    currCondDropDown.Items=condNames;
    currCondDropDown.Value=condNames{1};

end