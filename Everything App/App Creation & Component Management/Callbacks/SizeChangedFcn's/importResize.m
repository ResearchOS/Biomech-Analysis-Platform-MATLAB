function [fontSizeRelToHeight]=importResize(src)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE IMPORT TAB

data=src.UserData; % Get UserData to access components.

if isempty(data)
    return; % Called on uifigure creation
end

% Set components to be invisible

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
        initFontSize=get(data.ProjectNameField,'FontSize'); % Get the initial font size
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

%% Positions specified as relative to tab width & height
% All positions here are specified as relative positions
projectNameLabelRelPos=[0.02 0.9];
logsheetNameButtonRelPos=[0.02 0.85];
dataPathButtonRelPos=[0.02 0.8];
codePathButtonRelPos=[0.02 0.75];

projectNameEditFieldRelPos=[0.2 0.9]; % Width (relative) by height (relative)
logsheetNameEditFieldRelPos=[0.2 0.85];
dataPathEditFieldRelPos=[0.2 0.8];
codePathEditFieldRelPos=[0.2 0.75];
openImportSettingsButtonRelPos=[0.08 0.7];
openSpecifyTrialsButtonRelPos=[0.08 0.65];
projectDropDownRelPos=[0.65 0.9];
runImportButtonRelPos=[0.08 0.5];
openSpecifyVarsButtonRelPos=[0.08 0.6];
redoImportCheckboxRelPos=[0.7 0.5];
addDataTypesCheckboxRelPos=[0.7 0.45];
updateMetadataCheckboxRelPos=[0.7 0.4];
    
%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text
projectNameLabelSize=[0.18 compHeight];
logsheetNameButtonSize=[0.17 compHeight];
dataPathButtonSize=[0.15 compHeight];
codePathButtonSize=[0.15 compHeight];

projectNameEditFieldSize=[0.25 compHeight]; % Width (relative) by height (absolute)
logsheetNameEditFieldSize=[0.4 compHeight];
dataPathEditFieldSize=[0.4 compHeight];
codePathEditFieldSize=[0.4 compHeight];
openImportSettingsButtonSize=[0.4 compHeight];
openSpecifyTrialsButtonSize=[0.4 compHeight];
projectDropDownSize=[0.25 compHeight];
runImportButtonSize=[0.2 compHeight];
openSpecifyVarsButtonSize=[0.4 compHeight];
redoImportCheckboxSize=[0.3 compHeight];
addDataTypesCheckboxSize=[0.3 compHeight];
updateMetadataCheckboxSize=[0.3 compHeight];

% Multiply the relative positions by the figure size to get the actual position.
projectNameLabelPos=round([projectNameLabelRelPos.*figSize projectNameLabelSize(1)*figSize(1) projectNameLabelSize(2)]);
logsheetNameButtonPos=round([logsheetNameButtonRelPos.*figSize logsheetNameButtonSize(1)*figSize(1) logsheetNameButtonSize(2)]);
dataPathButtonPos=round([dataPathButtonRelPos.*figSize dataPathButtonSize(1)*figSize(1) dataPathButtonSize(2)]);
codePathButtonPos=round([codePathButtonRelPos.*figSize codePathButtonSize(1)*figSize(1) codePathButtonSize(2)]);

projectNameEditFieldPos=round([projectNameEditFieldRelPos.*figSize projectNameEditFieldSize(1)*figSize(1) projectNameEditFieldSize(2)]);
logsheetNameEditFieldPos=round([logsheetNameEditFieldRelPos.*figSize logsheetNameEditFieldSize(1)*figSize(1) logsheetNameEditFieldSize(2)]);
dataPathEditFieldPos=round([dataPathEditFieldRelPos.*figSize dataPathEditFieldSize(1)*figSize(1) dataPathEditFieldSize(2)]);
codePathEditFieldPos=round([codePathEditFieldRelPos.*figSize codePathEditFieldSize(1)*figSize(1) codePathEditFieldSize(2)]);
openImportSettingsButtonPos=round([openImportSettingsButtonRelPos.*figSize openImportSettingsButtonSize(1)*figSize(1) openImportSettingsButtonSize(2)]);
openSpecifyTrialsButtonPos=round([openSpecifyTrialsButtonRelPos.*figSize openSpecifyTrialsButtonSize(1)*figSize(1) openSpecifyTrialsButtonSize(2)]);
projectDropDownPos=round([projectDropDownRelPos.*figSize projectDropDownSize(1)*figSize(1) projectDropDownSize(2)]);
runImportButtonPos=round([runImportButtonRelPos.*figSize runImportButtonSize(1)*figSize(1) runImportButtonSize(2)]);
openSpecifyVarsButtonPos=round([openSpecifyVarsButtonRelPos.*figSize openSpecifyVarsButtonSize(1)*figSize(1) openSpecifyVarsButtonSize(2)]);
redoImportCheckboxPos=round([redoImportCheckboxRelPos.*figSize redoImportCheckboxSize(1)*figSize(1) redoImportCheckboxSize(2)]);
addDataTypesCheckboxPos=round([addDataTypesCheckboxRelPos.*figSize addDataTypesCheckboxSize(1)*figSize(1) addDataTypesCheckboxSize(2)]);
updateMetadataCheckBoxPos=round([updateMetadataCheckboxRelPos.*figSize updateMetadataCheckboxSize(1)*figSize(1) updateMetadataCheckboxSize(2)]);

% Set the actual positions for each component
data.ProjectNameLabel.Position=projectNameLabelPos;
data.LogsheetPathButton.Position=logsheetNameButtonPos;
data.DataPathButton.Position=dataPathButtonPos;
data.CodePathButton.Position=codePathButtonPos;
data.ProjectNameField.Position=projectNameEditFieldPos;
data.LogsheetPathField.Position=logsheetNameEditFieldPos;
data.DataPathField.Position=dataPathEditFieldPos;
data.CodePathField.Position=codePathEditFieldPos;
data.OpenImportSettingsButton.Position=openImportSettingsButtonPos;
data.OpenSpecifyTrialsButton.Position=openSpecifyTrialsButtonPos;
data.SwitchProjectsDropDown.Position=projectDropDownPos;
data.RunImportButton.Position=runImportButtonPos;
data.OpenSpecifyVarsButton.Position=openSpecifyVarsButtonPos;
data.RedoImportCheckBox.Position=redoImportCheckboxPos;
data.AddDataTypesCheckBox.Position=addDataTypesCheckboxPos;
data.UpdateMetadataCheckBox.Position=updateMetadataCheckBoxPos;

% Set the font sizes for all components that use text
data.ProjectNameLabel.FontSize=newFontSize;
data.LogsheetPathButton.FontSize=newFontSize;
data.DataPathButton.FontSize=newFontSize;
data.CodePathButton.FontSize=newFontSize;
data.ProjectNameField.FontSize=newFontSize;
data.LogsheetPathField.FontSize=newFontSize;
data.DataPathField.FontSize=newFontSize;
data.CodePathField.FontSize=newFontSize;
data.OpenImportSettingsButton.FontSize=newFontSize;
data.OpenSpecifyTrialsButton.FontSize=newFontSize;
data.SwitchProjectsDropDown.FontSize=newFontSize;
data.RunImportButton.FontSize=newFontSize;
data.OpenSpecifyVarsButton.FontSize=newFontSize;
data.RedoImportCheckBox.FontSize=newFontSize;
data.AddDataTypesCheckBox.FontSize=newFontSize;
data.UpdateMetadataCheckBox.FontSize=newFontSize;

% Restore component visibility