function []=argsResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS ON THE ARGS GUI

data=src.UserData; % Get UserData to access components.

if isempty(data)
    return; % Called on uifigure creation
end

% Modify component location
figSize=src.Position(3:4); % Width x height

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,defaultPos(3:4)) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(data.AllLabel,'FontSize'); % Get the initial font size
        fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
        setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
    end    
else
    fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
end

% Set new font size
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figure's height

if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end

%% Positions specified as relative to GUI width & height
allLabelRelPos=[0.1 0.95];
allOpenButtonRelPos=[0.05 0.9];
allArgsHardCodeCheckboxRelPos=[0.17 0.85];
allArgsProjectCheckboxRelPos=[0.02 0.85];
allArgsSubjectCheckboxRelPos=[0.07 0.85];
allArgsTrialCheckboxRelPos=[0.12 0.85];
allArgsListBoxRelPos=[0.02 0.08];
createArgButtonRelPos=[0.05 0.02];
deleteArgButtonRelPos=[0.12 0.02];
addArgsToFcnButtonRelPos=[0.23 0.6];
removeArgsFromFcnButtonRelPos=[0.23 0.5];
fcnLabelRelPos=[0.30 0.95];
fcnOpenButtonRelPos=[0.35 0.85];
fcnListBoxRelPos=[0.3 0.08];
fcnArgsVersionLabelRelPos=[0.5 0.95];
fcnArgsVersionDropDownRelPos=[0.65 0.95];
addFcnArgsVersionButtonRelPos=[0.77 0.95];
deleteFcnArgsVersionButtonRelPos=[0.85 0.95];
printFcnArgsButtonRelPos=[0.32 0.02];
syncToGroupButtonRelPos=[0.55 0.85];
isSyncedCheckboxRelPos=[0.72 0.85];
fullNicknameLabelRelPos=[0.55 0.75];
nameInCodeLabelRelPos=[0.55 0.7];
fullNicknameEditFieldRelPos=[0.7 0.75];
nameInCodeEditFieldRelPos=[0.7 0.7];
descriptionTextAreaRelPos=[0.55 0.02];
renameVarButtonRelPos=[0.75 0.8];

%% Component width specified relative to GUI width, height is in absolute units (constant)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text
allLabelSize=[0.1 compHeight];
allOpenButtonSize=[0.1 compHeight];
allArgsHardCodeCheckboxSize=[0.15 compHeight];
allArgsProjectCheckboxSize=[0.1 compHeight];
allArgsSubjectCheckboxSize=[0.1 compHeight];
allArgsTrialCheckboxSize=[0.05 compHeight];
allArgsListBoxSize=[0.2 0.75];
createArgButtonSize=[0.05 compHeight];
deleteArgButtonSize=[0.05 compHeight];
addArgsToFcnButtonSize=[0.05 compHeight];
removeArgsFromFcnButtonSize=[0.05 compHeight];
fcnLabelSize=[0.15 compHeight];
fcnOpenButtonSize=[0.1 compHeight];
fcnListBoxSize=[0.2 0.75];
fcnArgsVersionLabelSize=[0.15 compHeight];
fcnArgsVersionDropDownSize=[0.1 compHeight];
addFcnArgsVersionButtonSize=[0.05 compHeight];
deleteFcnArgsVersionButtonSize=[0.05 compHeight];
printFcnArgsButtonSize=[0.15 compHeight];
syncToGroupButtonSize=[0.15 compHeight];
isSyncedCheckboxSize=[0.05 compHeight];
fullNicknameLabelSize=[0.15 compHeight];
nameInCodeLabelSize=[0.15 compHeight];
fullNicknameEditFieldSize=[0.28 compHeight];
nameInCodeEditFieldSize=[0.28 compHeight];
descriptionTextAreaSize=[0.43 0.6];
renameVarButtonSize=[0.20 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.
allLabelPos=round([allLabelRelPos.*figSize allLabelSize(1)*figSize(1) allLabelSize(2)]);
allOpenButtonPos=round([allOpenButtonRelPos.*figSize allOpenButtonSize(1)*figSize(1) allOpenButtonSize(2)]);
allArgsHardCodeCheckboxPos=round([allArgsHardCodeCheckboxRelPos.*figSize allArgsHardCodeCheckboxSize(1)*figSize(1) allArgsHardCodeCheckboxSize(2)]);
allArgsProjectCheckboxPos=round([allArgsProjectCheckboxRelPos.*figSize allArgsProjectCheckboxSize(1)*figSize(1) allArgsProjectCheckboxSize(2)]);
allArgsSubjectCheckboxPos=round([allArgsSubjectCheckboxRelPos.*figSize allArgsSubjectCheckboxSize(1)*figSize(1) allArgsSubjectCheckboxSize(2)]);
allArgsTrialCheckboxPos=round([allArgsTrialCheckboxRelPos.*figSize allArgsTrialCheckboxSize(1)*figSize(1) allArgsTrialCheckboxSize(2)]);
allArgsListBoxPos=round([allArgsListBoxRelPos.*figSize allArgsListBoxSize.*figSize]);
createArgButtonPos=round([createArgButtonRelPos.*figSize createArgButtonSize(1)*figSize(1) createArgButtonSize(2)]);
deleteArgButtonPos=round([deleteArgButtonRelPos.*figSize deleteArgButtonSize(1)*figSize(1) deleteArgButtonSize(2)]);
addArgsToFcnButtonPos=round([addArgsToFcnButtonRelPos.*figSize addArgsToFcnButtonSize(1)*figSize(1) addArgsToFcnButtonSize(2)]);
removeArgsFromFcnButtonPos=round([removeArgsFromFcnButtonRelPos.*figSize removeArgsFromFcnButtonSize(1)*figSize(1) removeArgsFromFcnButtonSize(2)]);
fcnLabelPos=round([fcnLabelRelPos.*figSize fcnLabelSize(1)*figSize(1) fcnLabelSize(2)]);
fcnOpenButtonPos=round([fcnOpenButtonRelPos.*figSize fcnOpenButtonSize(1)*figSize(1) fcnOpenButtonSize(2)]);
fcnListBoxPos=round([fcnListBoxRelPos.*figSize fcnListBoxSize.*figSize]);
fcnArgsVersionLabelPos=round([fcnArgsVersionLabelRelPos.*figSize fcnArgsVersionLabelSize(1)*figSize(1) fcnArgsVersionLabelSize(2)]);
fcnArgsVersionDropDownPos=round([fcnArgsVersionDropDownRelPos.*figSize fcnArgsVersionDropDownSize(1)*figSize(1) fcnArgsVersionDropDownSize(2)]);
addFcnArgsVersionButtonPos=round([addFcnArgsVersionButtonRelPos.*figSize addFcnArgsVersionButtonSize(1)*figSize(1) addFcnArgsVersionButtonSize(2)]);
deleteFcnArgsVersionButtonPos=round([deleteFcnArgsVersionButtonRelPos.*figSize deleteFcnArgsVersionButtonSize(1)*figSize(1) deleteFcnArgsVersionButtonSize(2)]);
printFcnArgsButtonPos=round([printFcnArgsButtonRelPos.*figSize printFcnArgsButtonSize(1)*figSize(1) printFcnArgsButtonSize(2)]);
syncToGroupButtonPos=round([syncToGroupButtonRelPos.*figSize syncToGroupButtonSize(1)*figSize(1) syncToGroupButtonSize(2)]);
isSyncedCheckboxPos=round([isSyncedCheckboxRelPos.*figSize isSyncedCheckboxSize(1)*figSize(1) isSyncedCheckboxSize(2)]);
fullNicknameLabelPos=round([fullNicknameLabelRelPos.*figSize fullNicknameLabelSize(1)*figSize(1) fullNicknameLabelSize(2)]);
nameInCodeLabelPos=round([nameInCodeLabelRelPos.*figSize nameInCodeLabelSize(1)*figSize(1) nameInCodeLabelSize(2)]);
fullNicknameEditFieldPos=round([fullNicknameEditFieldRelPos.*figSize fullNicknameEditFieldSize(1)*figSize(1) fullNicknameEditFieldSize(2)]);
nameInCodeEditFieldPos=round([nameInCodeEditFieldRelPos.*figSize nameInCodeEditFieldSize(1)*figSize(1) nameInCodeEditFieldSize(2)]);
descriptionTextAreaPos=round([descriptionTextAreaRelPos.*figSize descriptionTextAreaSize.*figSize]);
renameVarButtonPos=round([renameVarButtonRelPos.*figSize renameVarButtonSize(1)*figSize(1) renameVarButtonSize(2)]);

%% Set the actual positions for each component
data.AllLabel.Position=allLabelPos;
data.AllOpenButton.Position=allOpenButtonPos;
data.AllArgsHardCodeCheckbox.Position=allArgsHardCodeCheckboxPos;
data.AllArgsProjectCheckbox.Position=allArgsProjectCheckboxPos;
data.AllArgsSubjectCheckbox.Position=allArgsSubjectCheckboxPos;
data.AllArgsTrialCheckbox.Position=allArgsTrialCheckboxPos;
data.AllArgsListBox.Position=allArgsListBoxPos;
data.CreateArgButton.Position=createArgButtonPos;
data.DeleteArgButton.Position=deleteArgButtonPos;
data.AddArgsToFcnButton.Position=addArgsToFcnButtonPos;
data.RemoveArgsFromFcnButton.Position=removeArgsFromFcnButtonPos;
data.FcnLabel.Position=fcnLabelPos;
data.FcnOpenButton.Position=fcnOpenButtonPos;
data.FcnListBox.Position=fcnListBoxPos;
data.FcnArgsVersionLabel.Position=fcnArgsVersionLabelPos;
data.FcnArgsVersionDropDown.Position=fcnArgsVersionDropDownPos;
data.AddFcnArgsVersionButton.Position=addFcnArgsVersionButtonPos;
data.DeleteFcnArgsVersionButton.Position=deleteFcnArgsVersionButtonPos;
data.PrintFcnArgsButton.Position=printFcnArgsButtonPos;
data.SyncToGroupButton.Position=syncToGroupButtonPos;
data.IsSyncedCheckbox.Position=isSyncedCheckboxPos;
data.FullNicknameLabel.Position=fullNicknameLabelPos;
data.NameInCodeLabel.Position=nameInCodeLabelPos;
data.FullNicknameEditField.Position=fullNicknameEditFieldPos;
data.NameInCodeEditField.Position=nameInCodeEditFieldPos;
data.DescriptionTextArea.Position=descriptionTextAreaPos;
data.RenameVarButton.Position=renameVarButtonPos;

%% Set the font sizes for all components that use text
data.AllLabel.FontSize=newFontSize;
data.AllOpenButton.FontSize=newFontSize;
data.AllArgsHardCodeCheckbox.FontSize=newFontSize;
data.AllArgsProjectCheckbox.FontSize=newFontSize;
data.AllArgsSubjectCheckbox.FontSize=newFontSize;
data.AllArgsTrialCheckbox.FontSize=newFontSize;
data.AllArgsListBox.FontSize=newFontSize;
data.CreateArgButton.FontSize=newFontSize;
data.DeleteArgButton.FontSize=newFontSize;
data.AddArgsToFcnButton.FontSize=newFontSize;
data.RemoveArgsFromFcnButton.FontSize=newFontSize;
data.FcnLabel.FontSize=newFontSize;
data.FcnOpenButton.FontSize=newFontSize;
data.FcnListBox.FontSize=newFontSize;
data.FcnArgsVersionLabel.FontSize=newFontSize;
data.FcnArgsVersionDropDown.FontSize=newFontSize;
data.AddFcnArgsVersionButton.FontSize=newFontSize;
data.DeleteFcnArgsVersionButton.FontSize=newFontSize;
data.PrintFcnArgsVersionButton.FontSize=newFontSize;
data.SyncToGroupButton.FontSize=newFontSize;
data.IsSyncedCheckbox.FontSize=newFontSize;
data.FullNicknameLabel.FontSize=newFontSize;
data.NameInCodeLabel.FontSize=newFontSize;
data.FullNicknameEditField.FontSize=newFontSize;
data.NameInCodeEditField.FontSize=newFontSize;
data.DescriptionTextArea.FontSize=newFontSize;
data.RenameVarButton.FontSize=newFontSize;
