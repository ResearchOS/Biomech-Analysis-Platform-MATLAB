function []=specifyTrialsButtonPushedPopupWindow(src,guiLocation)

%% PURPOSE: CREATE GUI TO FACILITATE SPECIFY TRIALS SELECTION.
% Inputs:
% src: The figure object (handle)
% guiLocation: Where in the GUI the specify trials is being called from (char)
% Possible values:
% 'Import': The Import tab
% 'Process Group groupName': The Process > Run tab, for the group groupName
% 'Process Fcn fcnName': The Process > Run tab, for the function fcnName
% 'Plot fcnName': The Plot tab, for the function fcnName

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fig=ancestor(src,'figure','toplevel');
assignin('base','gui',fig); % Send the fig handle to the base workspace.
% handles=getappdata(fig,'handles');

clc;
Q=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@specifyTrialsResize);
Q.Name='Specify Trials'; % Name the window
defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(Q,'Position',defaultPos); % Set the figure to be at that position (redundant, I know, but should be clear)
setappdata(Q,'guiLocation',guiLocation);
% figSize=get(Q,'Position'); % Get the figure's position.
% figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)

newHandles.Top.specifyTrialsLabel=uilabel(Q,'Text','Specify Trials Version','Tag','SpecifyTrialsLabel');
newHandles.Top.specifyTrialsDropDown=uidropdown(Q,'Items',{'Add Specify Trials Version'},'Tooltip','Select Which Specify Trials to Use, or Add New','Editable','off','Tag','SpecifyTrialsDropDown','ValueChangedFcn',@(specifyTrialsDropDown, event) specifyTrialsVersionDropDownValueChanged(specifyTrialsDropDown));
newHandles.Top.specifyTrialsDropDownAdd=uibutton(Q,'push','Tooltip','Add New Specify Trials Version','Text','+','Tag','SpecifyTrialsDropDownAdd','ButtonPushedFcn',@(specifyTrialsDropDown,event) specifyTrialsDropDownAddButtonPushed(specifyTrialsDropDown));
newHandles.Top.specifyTrialsDropDownRemove=uibutton(Q,'push','Tooltip','Remove Specify Trials Version','Text','-','Tag','SpecifyTrialsDropDownRemove','ButtonPushedFcn',@(specifyTrialsDropDown,event) specifyTrialsDropDownRemoveButtonPushed(specifyTrialsDropDown));
% Create the tab group for inclusion vs. exclusion criteria.
newHandles.Top.includeExcludeTabGroup=uitabgroup(Q,'AutoResizeChildren','off'); % Full width, 85% height
newHandles.Top.includeTab=uitab(newHandles.Top.includeExcludeTabGroup,'Title','Include','AutoResizeChildren','off','SizeChangedFcn',@specifyTrialsResize);
newHandles.Top.excludeTab=uitab(newHandles.Top.includeExcludeTabGroup,'Title','Exclude','AutoResizeChildren','off','SizeChangedFcn',@specifyTrialsResize);

newHandles.Include.conditionLabel=uilabel(newHandles.Top.includeTab,'Text','Condition Name','Tag','IncludeConditionLabel');
newHandles.Include.conditionDropDown=uidropdown(newHandles.Top.includeTab,'Items',{'Add Condition Name'},'Tag','IncludeConditionDropDown','ValueChangedFcn',@(includeConditionDropDown,event) conditionNameDropDownValueChanged(includeConditionDropDown));
newHandles.Include.addConditionButton=uibutton(newHandles.Top.includeTab,'Text','+','Tag','IncludeAddConditionButton','Tooltip','Add New Inclusion Condition','ButtonPushedFcn',@(includeAddConditionButton,event) addConditionNameButtonPushed(includeAddConditionButton));
newHandles.Include.removeConditionButton=uibutton(newHandles.Top.includeTab,'Text','-','Tag','IncludeRemoveConditionButton','Tooltip','Remove Inclusion Condition','ButtonPushedFcn',@(includeRemoveConditionButton,event) removeConditionNameButtonPushed(includeRemoveConditionButton));
newHandles.Include.logStructTabGroup=uitabgroup(newHandles.Top.includeTab,'AutoResizeChildren','off');
newHandles.Include.LogTab=uitab(newHandles.Include.logStructTabGroup,'Title','Logsheet','Tag','IncludeLogsheetTab','AutoResizeChildren','off','SizeChangedFcn',@specifyTrialsResize);
newHandles.Include.StructTab=uitab(newHandles.Include.logStructTabGroup,'Title','Structure','AutoResizeChildren','off','Tag','IncludeStructTab','SizeChangedFcn',@specifyTrialsResize);
newHandles.Include.UpArrowButton=uibutton(newHandles.Top.includeTab,'push','Text',{'/\';'||'},'Tag','IncludeUpArrowButton','ButtonPushedFcn',@(includeUpArrowButton,event) includeUpArrowButtonPushed(includeUpArrowButton));
newHandles.Include.DownArrowButton=uibutton(newHandles.Top.includeTab,'push','Text',{'||';'\/'},'Tag','IncludeDownArrowButton','ButtonPushedFcn',@(includeDownArrowButton,event) includeDownArrowButtonPushed(includeDownArrowButton));

newHandles.Exclude.conditionLabel=uilabel(newHandles.Top.excludeTab,'Text','Condition Name','Tag','ExcludeConditionLabel');
newHandles.Exclude.conditionDropDown=uidropdown(newHandles.Top.excludeTab,'Items',{'Add Condition Name'},'Tag','ExcludeConditionDropDown','ValueChangedFcn',@(excludeConditionDropDown,event) conditionNameDropDownValueChanged(excludeConditionDropDown));
newHandles.Exclude.addConditionButton=uibutton(newHandles.Top.excludeTab,'Text','+','Tag','ExcludeAddConditionButton','Tooltip','Add New Exclusion Condition','ButtonPushedFcn',@(excludeAddConditionButton,event) addConditionNameButtonPushed(excludeAddConditionButton));
newHandles.Exclude.removeConditionButton=uibutton(newHandles.Top.excludeTab,'Text','-','Tag','ExcludeRemoveConditionButton','Tooltip','Remove Exclusion Condition','ButtonPushedFcn',@(excludeRemoveConditionButton,event) removeConditionNameButtonPushed(excludeRemoveConditionButton));
newHandles.Exclude.logStructTabGroup=uitabgroup(newHandles.Top.excludeTab,'AutoResizeChildren','off');
newHandles.Exclude.LogTab=uitab(newHandles.Exclude.logStructTabGroup,'Title','Logsheet','AutoResizeChildren','off','Tag','ExcludeLogsheetTab','SizeChangedFcn',@specifyTrialsResize);
newHandles.Exclude.StructTab=uitab(newHandles.Exclude.logStructTabGroup,'Title','Structure','AutoResizeChildren','off','Tag','ExcludeStructTab','SizeChangedFcn',@specifyTrialsResize);
newHandles.Exclude.UpArrowButton=uibutton(newHandles.Top.excludeTab,'push','Text',{'/\';'||'},'Tag','ExcludeUpArrowButton','ButtonPushedFcn',@(excludeUpArrowButton,event) excludeUpArrowButtonPushed(excludeUpArrowButton));
newHandles.Exclude.DownArrowButton=uibutton(newHandles.Top.excludeTab,'push','Text',{'||';'\/'},'Tag','ExcludeDownArrowButton','ButtonPushedFcn',@(excludeDownArrowButton,event) excludeDownArrowButtonPushed(excludeDownArrowButton));

Q.UserData=struct('IncludeExcludeTabGroup',newHandles.Top.includeExcludeTabGroup,'SpecifyTrialsLabel',newHandles.Top.specifyTrialsLabel,'SpecifyTrialsDropDown',newHandles.Top.specifyTrialsDropDown,'SpecifyTrialsDropDownAdd',newHandles.Top.specifyTrialsDropDownAdd,'SpecifyTrialsDropDownRemove',newHandles.Top.specifyTrialsDropDownRemove,...
    'IncludeConditionLabel',newHandles.Include.conditionLabel,'IncludeConditionDropDown',newHandles.Include.conditionDropDown,'IncludeAddConditionButton',newHandles.Include.addConditionButton,'IncludeRemoveConditionButton',newHandles.Include.removeConditionButton,'IncludeLogStructTabGroup',newHandles.Include.logStructTabGroup,...
    'ExcludeConditionLabel',newHandles.Exclude.conditionLabel,'ExcludeConditionDropDown',newHandles.Exclude.conditionDropDown,'ExcludeAddConditionButton',newHandles.Exclude.addConditionButton,'ExcludeRemoveConditionButton',newHandles.Exclude.removeConditionButton,'ExcludeLogStructTabGroup',newHandles.Exclude.logStructTabGroup,...
    'IncludeUpArrowButton',newHandles.Include.UpArrowButton,'IncludeDownArrowButton',newHandles.Include.DownArrowButton,'ExcludeUpArrowButton',newHandles.Exclude.UpArrowButton,'ExcludeDownArrowButton',newHandles.Exclude.DownArrowButton);

specifyTrialsResize(Q); % Initialize all components' positions.

% Read the text file, and the pgui fig, to set the initial value of the specify trials drop down. Then, call the specifyTrialsVersionValueChanged
% callback function to propagate those changes throughout the GUI.
[text,allProjectsSpecifyTrialsPath]=readSpecifyTrials(getappdata(fig,'everythingPath'));
setappdata(Q,'allProjectsSpecifyTrialsPath',allProjectsSpecifyTrialsPath);
setappdata(fig,'allProjectsSpecifyTrialsPath',allProjectsSpecifyTrialsPath);
setappdata(Q,'everythingPath',getappdata(fig,'everythingPath'));
if iscell(text) % The file exists and has a pre-existing project in it.
    allProjectsList=getAllProjectNames(text);
else
    allProjectsList='';
end
assert(isempty(allProjectsList) || isequal(allProjectsList,getappdata(fig,'allProjectsList'))); % Check that this text file matches the allProjects_NamesPaths.txt file.

currProjectLine=0; % Initialize that the project has not been found (i.e. on line 0).
allNames={''}; % Contains all version names
allNamesCount=0;
if ~isempty(allProjectsList)
    numLines=length(text);
    projectNameLine=['Project Name: ' getappdata(fig,'projectName')];
    for i=1:numLines

        if isequal(text{i}(1:length(projectNameLine)),projectNameLine)
            currProjectLine=i;            
            continue;
        end          

        if currProjectLine==0
            continue;
        end

        if isempty(text{i}) % Done with the current project.
            break;
        end

        % Now in the current project. Read all pre-existing specify trials, and determine which one should be in the current drop down value.

        colonIdx=strfind(text{i},':'); % All lines start with a semicolon, even if no gui location prefix.
        colonIdx=colonIdx(1); % Isolate the first colon
        mNameStartIdx=colonIdx+2; % Idx of the first char of the mfilename on this line

        mName=text{i}(mNameStartIdx:end); % The m file path
        mNameSplit=strsplit(mName,slash);
        vName=strsplit(mNameSplit{end},['_' getappdata(fig,'projectName')]);
        vName=vName{1}; % Cell to char
        allNamesCount=allNamesCount+1;
        allNames{allNamesCount}=vName;

        currLoc=strfind(text{i}(1:colonIdx),guiLocation); % Find if the current location is in this line of text before the semicolon.

        % If the current line is 
        if ~isempty(vName) && any([isequal(guiLocation,'Import') && isequal(text{i}(1:6),'Import') ...
                contains(guiLocation,'Process Group') contains(guiLocation,'Process Fcn') contains(guiLocation,'Plot Fcn')]) && ~isempty(currLoc)
            % Now in the desired specify trials version
            currVName=vName;
        end        

    end

    if ~exist('currVName','var')
        currVName=allNames{1};
    end

    newHandles.Top.specifyTrialsDropDown.Items=allNames;
    newHandles.Top.specifyTrialsDropDown.Value=currVName;

end

setappdata(Q,'handles',newHandles);

specifyTrialsVersionDropDownValueChanged(Q);
