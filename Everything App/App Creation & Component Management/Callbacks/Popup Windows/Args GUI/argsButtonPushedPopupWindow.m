function []=argsButtonPushedPopupWindow(src,guiTab,fcnName,groupName)

%% PURPOSE: TO FACILITATE SELECTING ARGS FOR SPECIFIC FUNCTIONS
% Inputs:
% src: The figure object (handle)
% guiLocation: Where in the GUI the args button was pushed (char)
% Possible values:
% 'Import dataType': The Import tab, for a specific data type.
% 'Process Fcn fcnName': The Process > Run tab, for the function fcnName
% 'Plot fcnName': The Plot tab, for the function fcnName
% fcnName: The current function to change args for (char)

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fig=ancestor(src,'figure','toplevel');

allHandles=findall(0);
for i=1:length(allHandles)

        if isprop(allHandles(i),'Name') && contains(allHandles(i).Name,'Args')
            warning(['Close the open args window before opening a new one!']);
            return;
        end

end

%% Initialize GUI
clc;
Q=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@argsResize);
Q.Name=['Args for ' fcnName];
defaultPos=get(0,'defaultfigureposition');
set(Q,'Position',defaultPos);
setappdata(Q,'guiTab',guiTab);
setappdata(Q,'fcnName',fcnName);
setappdata(Q,'groupName',groupName);

newHandles.allLabel=uilabel(Q,'Text','All','Tag','AllLabel');
newHandles.allOpenButton=uibutton(Q,'push','Tooltip','Open selected arg from All list','Text','open','Tag','AllOpenButton','ButtonPushedFcn',@(allOpenButton,event) allOpenButtonPushed(allOpenButton));
newHandles.allArgsHardCodeCheckbox=uicheckbox(Q,'Text','Hard-coded','Value',0,'Tag','AllArgsHardCodeCheckbox','Tooltip','Select this to filter for hard-coded args','ValueChangedFcn',@(allArgsHardCodeCheckbox,event) allArgsFilterCheckboxChecked(allArgsHardCodeCheckbox));
newHandles.allArgsProjectCheckbox=uicheckbox(Q,'Text','P','Value',0,'Tag','AllArgsProjectCheckbox','Tooltip','Select this to filter for project level args','ValueChangedFcn',@(allArgsProjectCheckbox,event) allArgsFilterCheckboxChecked(allArgsProjectCheckbox));
newHandles.allArgsSubjectCheckbox=uicheckbox(Q,'Text','S','Value',0,'Tag','AllArgsSubjectCheckbox','Tooltip','Select this to filter for subject level args','ValueChangedFcn',@(allArgsSubjectCheckbox,event) allArgsFilterCheckboxChecked(allArgsSubjectCheckbox));
newHandles.allArgsTrialCheckbox=uicheckbox(Q,'Text','T','Value',0,'Tag','AllArgsTrialCheckbox','Tooltip','Select this to filter for trial level args','ValueChangedFcn',@(allArgsTrialCheckbox,event) allArgsFilterCheckboxChecked(allArgsTrialCheckbox));
newHandles.allArgsListBox=uilistbox(Q,'MultiSelect','on','Items',{'No Args'},'Value','No Args','Tooltip','Select from list of all args','Tag','AllArgsListBox','ValueChangedFcn',@(allArgsListBox,event) allArgsListBoxValueChanged(allArgsListBox));
newHandles.createArgButton=uibutton(Q,'push','Tooltip','Create new argument, add to All args list','Text','+','Tag','CreateArgButton','ButtonPushedFcn',@(createArgButton,event) createArgButtonPushed(createArgButton));
newHandles.deleteArgButton=uibutton(Q,'push','Tooltip','Delete selected argument from All args list and all functions','Text','-','Tag','DeleteArgButton','ButtonPushedFcn',@(deleteArgButton,event) deleteArgButtonPushed(deleteArgButton));
newHandles.addArgsToFcnButton=uibutton(Q,'push','Text','=>','Tooltip','Add selected args from All to current function','Tag','AddArgsToFcnButon','ButtonPushedFcn',@(addArgsToFcnButton,event) addArgsToFcnButtonPushed(addArgsToFcnButton));
newHandles.removeArgsFromFcnButton=uibutton(Q,'push','Text','<=','Tooltip','Remove selected args from current function','Tag','RemoveArgsFromFcnButon','ButtonPushedFcn',@(removeArgsFromFcnButton,event) removeArgsFromFcnButtonPushed(removeArgsFromFcnButton));
newHandles.fcnLabel=uilabel(Q,'Text','Current Function','Tag','FcnNameLabel','WordWrap','on');
newHandles.fcnOpenButton=uibutton(Q,'push','Tooltip','Open select arg from current function list','Text','open','Tag','FcnOpenButton','ButtonPushedFcn',@(fcnOpenButton,event) fcnOpenButtonPushed(fcnOpenButton));
newHandles.fcnListBox=uilistbox(Q,'MultiSelect','on','Items',{'No Args'},'Value','No Args','Tooltip','The input & output argument names for the current function','Tag','FcnListBox','ValueChangedFcn',@(fcnListBox,event) fcnListBoxValueChanged(fcnListBox));
newHandles.fcnArgsVersionLabel=uilabel(Q,'Text','Fcn Args Version','Tag','FcnArgsVersionLabel');
newHandles.fcnArgsVersionDropDown=uidropdown(Q,'Items',{'A'},'Value','A','Tooltip','Switch between sets of arguments for the current function','Editable','off','Tag','FcnArgsVersionDropDown','ValueChangedFcn',@(fcnArgsVersionDropDown,event) fcnArgsVersionDropDownValueChanged(fcnArgsVersionDropDown));
newHandles.addFcnArgsVersionButton=uibutton(Q,'push','Text','+','Tag','AddFcnArgsVersion','Tooltip','Add another args version to this function. Copies from the current version','ButtonPushedFcn',@(addFcnArgsVersionButton,event) addFcnArgsVersionButtonPushed(addFcnArgsVersionButton));
newHandles.deleteFcnArgsVersionButton=uibutton(Q,'push','Text','-','Tag','DeleteFcnArgsVersion','Tooltip','Delete the current args version from this function','ButtonPushedFcn',@(deleteFcnArgsVersionButton,event) deleteFcnArgsVersionButtonPushed(deleteFcnArgsVersionButton));
newHandles.printFcnArgsButton=uibutton(Q,'push','Tooltip','Print the current args to the command window to copy and paste into code','Tag','PrintFcnArgsButton','Text','Print Fcn Args','ButtonPushedFcn',@(printFcnArgsButton,event) printFcnArgsButtonPushed(printFcnArgsButton));
newHandles.syncToGroupButton=uibutton(Q,'push','Text','Sync to Group','Tooltip','Sync this argument to every function in the processing group that uses it','Tag','SyncToGroupButton','ButtonPushedFcn',@(syncToGroupButton,event) syncToGroupButtonPushed(syncToGroupButton));
newHandles.isSyncedCheckbox=uicheckbox(Q,'Tooltip','Select to keep synced to group. Deselect to revert to unique value','Text','','Tag','IsSyncedCheckbox','ValueChangedFcn',@(isSyncedCheckbox,event) isSyncedCheckboxValueChanged(isSyncedCheckbox));
newHandles.fullNicknameLabel=uilabel(Q,'Text','Full Nickname','Tag','FullNicknameLabel');
newHandles.nameInCodeLabel=uilabel(Q,'Text','Name In Code','Tag','NameInCodeLabel');
newHandles.fullNicknameEditField=uieditfield(Q,'text','Value','','Tag','FullNicknameEditField','Tooltip','The arg name in the list (in case it was cut off)','Editable','off');
newHandles.nameInCodeEditField=uieditfield(Q,'text','Value','','Tag','NameInCodeEditField','Tooltip','How the arg is referred to in this function. Can be function-specific or common across this processing group','Editable','on','ValueChangedFcn',@(nameInCodeEditField,event) nameInCodeEditFieldValueChanged(nameInCodeEditField));
newHandles.descriptionTextArea=uitextarea(Q,'Value','Enter Description Here','Tooltip','Description of what this arg is and how it was computed','Editable','on','Tag','DescriptionTextArea','ValueChangedFcn',@(descriptionTextArea,event) descriptionTextAreaValueChanged(descriptionTextArea));

Q.UserData=struct('AllLabel',newHandles.allLabel,'AllOpenButton',newHandles.allOpenButton,'AllArgsHardCodeCheckbox',newHandles.allArgsHardCodeCheckbox,'AllArgsProjectCheckbox',newHandles.allArgsProjectCheckbox,'AllArgsSubjectCheckbox',newHandles.allArgsSubjectCheckbox,'AllArgsTrialCheckbox',newHandles.allArgsTrialCheckbox,...
    'AllArgsListBox',newHandles.allArgsListBox,'CreateArgButton',newHandles.createArgButton,'DeleteArgButton',newHandles.deleteArgButton,'AddArgsToFcnButton',newHandles.addArgsToFcnButton,'RemoveArgsFromFcnButton',newHandles.removeArgsFromFcnButton,'FcnLabel',newHandles.fcnLabel,'FcnOpenButton',newHandles.fcnOpenButton,...
    'FcnListBox',newHandles.fcnListBox,'FcnArgsVersionLabel',newHandles.fcnArgsVersionLabel,'FcnArgsVersionDropDown',newHandles.fcnArgsVersionDropDown,'AddFcnArgsVersionButton',newHandles.addFcnArgsVersionButton,'DeleteFcnArgsVersionButton',newHandles.deleteFcnArgsVersionButton,'PrintFcnArgsButton',newHandles.printFcnArgsButton,...
    'SyncToGroupButton',newHandles.syncToGroupButton,'IsSyncedCheckbox',newHandles.isSyncedCheckbox,'FullNicknameLabel',newHandles.fullNicknameLabel,'NameInCodeLabel',newHandles.nameInCodeLabel,'FullNicknameEditField',newHandles.fullNicknameEditField,'NameInCodeEditField',newHandles.nameInCodeEditField,'DescriptionTextArea',newHandles.descriptionTextArea);

argsResize(Q);

%% Initialize settings
% Read the text file, and the pgui fig, to set the initial value of the args lists, the args version drop down, the sync to group checkbox, and the
% edit fields
[text,currProjectArgsTxtPath]=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),guiTab);
setappdata(Q,'currProjectArgsTxtPath',currProjectArgsTxtPath);
setappdata(fig,'currProjectArgsTxtPath',currProjectArgsTxtPath);
setappdata(Q,'everythingPath',getappdata(fig,'everythingPath'));
setappdata(Q,'projectName',getappdata(fig,'projectName'));
setappdata(Q,'codePath',getappdata(fig,'codePath'));

% Set the all args list box
if iscell(text) % The file exists and has pre-existing args in it
    allArgsList=getAllArgNames(text,getappdata(fig,'projectName'),guiTab);
else
    allArgsList='';
end

if ~isempty(allArgsList)
    newHandles.allArgsListBox.Items=allArgsList;
end

% Set the version letter drop down items based on all function names found in the text file with the same base name, guiTab, and number.
fcnNameSplit=strsplit(fcnName,'_');
underscoreIdx=strfind(fcnName,'_');
fcnNameOnly=fcnName(1:underscoreIdx(end)-1);
suffix=fcnNameSplit{end};
methodID=suffix(length(guiTab)+1:end); % Number & letter only
methodLetter=methodID(isstrprop(methodID,'alpha'));
methodNum=methodID(isstrprop(methodID,'digit'));

if iscell(text) && ~isempty(text{1})
    allLetters=getAllArgLetters(text,getappdata(fig,'projectName'),guiTab,fcnNameOnly,methodNum);
else
    allLetters={methodLetter};
end
newHandles.fcnArgsVersionDropDown.Items=allLetters;

% Set the current version letter based off of the function name input.
assert(ismember(methodLetter,allLetters));
newHandles.fcnArgsVersionDropDown.Value=methodLetter;

assignin('base','gui',fig);
setappdata(Q,'handles',newHandles);
fcnArgsVersionDropDownValueChanged(Q);