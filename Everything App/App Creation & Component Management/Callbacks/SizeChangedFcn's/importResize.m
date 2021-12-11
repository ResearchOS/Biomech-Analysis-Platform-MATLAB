function [fontSizeRelToHeight]=importResize(src, event)

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
openImportMetadataButtonRelPos=[0.65 0.7];
openSpecifyTrialsButtonRelPos=[0.08 0.65];
projectDropDownRelPos=[0.65 0.9];
runImportButtonRelPos=[0.75 0.2];
redoImportCheckboxRelPos=[0.7 0.85];
% updateMetadataCheckboxRelPos=[0.7 0.8];
dataTypeImportSettingsDropDownRelPos=[0.65 0.75];
logsheetLabelRelPos=[0.5 0.6];
numHeaderRowsLabelRelPos=[0.5 0.55];
numHeaderRowsFieldRelPos=[0.7 0.55];
subjectIDColHeaderLabelRelPos=[0.5 0.5];
subjectIDColHeaderFieldRelPos=[0.7 0.5];
trialIDColHeaderLabelRelPos=[0.5 0.45];
trialIDColHeaderFieldRelPos=[0.7 0.45];
trialIDFormatLabelRelPos=[0.5 0.4];
trialIDFormatFieldRelPos=[0.7 0.4];
targetTrialIDFormatLabelRelPos=[0.5 0.35];
targetTrialIDFormatFieldRelPos=[0.7 0.35];
saveAllButtonRelPos=[0.75 0.25];
selectDataPanelRelPos=[0.05 0.05];
dataTypeImportMethodFieldRelPos=[0.93 0.75];
addDataTypeButtonRelPos=[0.65 0.8];
openImportFcnButtonRelPos=[0.65 0.65];
    
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
openImportMetadataButtonSize=[0.2 compHeight];
openSpecifyTrialsButtonSize=[0.4 compHeight];
projectDropDownSize=[0.35 compHeight];
runImportButtonSize=[0.2 compHeight];
redoImportCheckboxSize=[0.3 compHeight];
% updateMetadataCheckboxSize=[0.3 compHeight];
dataTypeImportSettingsDropDownSize=[0.25 compHeight];
logsheetLabelSize=[0.2 compHeight];
numHeaderRowsLabelSize=[0.2 compHeight];
numHeaderRowsFieldSize=[0.1 compHeight];
subjectIDColHeaderLabelSize=[0.2 compHeight];
subjectIDColHeaderFieldSize=[0.2 compHeight];
trialIDColHeaderLabelSize=[0.2 compHeight];
trialIDColHeaderFieldSize=[0.2 compHeight];
trialIDFormatLabelSize=[0.2 compHeight];
trialIDFormatFieldSize=[0.2 compHeight];
targetTrialIDFormatLabelSize=[0.2 compHeight];
targetTrialIDFormatFieldSize=[0.2 compHeight];
saveAllButtonSize=[0.2 compHeight];
selectDataPanelSize=[0.4 0.55*figSize(2)];
dataTypeImportMethodFieldSize=[0.05 compHeight];
addDataTypeButtonSize=[0.2 compHeight];
openImportFcnButtonSize=[0.2 compHeight];

% Multiply the relative positions by the figure size to get the actual position.
projectNameLabelPos=round([projectNameLabelRelPos.*figSize projectNameLabelSize(1)*figSize(1) projectNameLabelSize(2)]);
logsheetNameButtonPos=round([logsheetNameButtonRelPos.*figSize logsheetNameButtonSize(1)*figSize(1) logsheetNameButtonSize(2)]);
dataPathButtonPos=round([dataPathButtonRelPos.*figSize dataPathButtonSize(1)*figSize(1) dataPathButtonSize(2)]);
codePathButtonPos=round([codePathButtonRelPos.*figSize codePathButtonSize(1)*figSize(1) codePathButtonSize(2)]);
projectNameEditFieldPos=round([projectNameEditFieldRelPos.*figSize projectNameEditFieldSize(1)*figSize(1) projectNameEditFieldSize(2)]);
logsheetNameEditFieldPos=round([logsheetNameEditFieldRelPos.*figSize logsheetNameEditFieldSize(1)*figSize(1) logsheetNameEditFieldSize(2)]);
dataPathEditFieldPos=round([dataPathEditFieldRelPos.*figSize dataPathEditFieldSize(1)*figSize(1) dataPathEditFieldSize(2)]);
codePathEditFieldPos=round([codePathEditFieldRelPos.*figSize codePathEditFieldSize(1)*figSize(1) codePathEditFieldSize(2)]);
openImportMetadataButtonPos=round([openImportMetadataButtonRelPos.*figSize openImportMetadataButtonSize(1)*figSize(1) openImportMetadataButtonSize(2)]);
openSpecifyTrialsButtonPos=round([openSpecifyTrialsButtonRelPos.*figSize openSpecifyTrialsButtonSize(1)*figSize(1) openSpecifyTrialsButtonSize(2)]);
projectDropDownPos=round([projectDropDownRelPos.*figSize projectDropDownSize(1)*figSize(1) projectDropDownSize(2)]);
runImportButtonPos=round([runImportButtonRelPos.*figSize runImportButtonSize(1)*figSize(1) runImportButtonSize(2)]);
redoImportCheckboxPos=round([redoImportCheckboxRelPos.*figSize redoImportCheckboxSize(1)*figSize(1) redoImportCheckboxSize(2)]);
% updateMetadataCheckBoxPos=round([updateMetadataCheckboxRelPos.*figSize updateMetadataCheckboxSize(1)*figSize(1) updateMetadataCheckboxSize(2)]);
dataTypeImportSettingsDropDownPos=round([dataTypeImportSettingsDropDownRelPos.*figSize dataTypeImportSettingsDropDownSize(1)*figSize(1) dataTypeImportSettingsDropDownSize(2)]);

logsheetLabelPos=round([logsheetLabelRelPos.*figSize logsheetLabelSize(1)*figSize(1) logsheetLabelSize(2)]);
numHeaderRowsLabelPos=round([numHeaderRowsLabelRelPos.*figSize numHeaderRowsLabelSize(1)*figSize(1) numHeaderRowsLabelSize(2)]);
numHeaderRowsFieldPos=round([numHeaderRowsFieldRelPos.*figSize numHeaderRowsFieldSize(1)*figSize(1) numHeaderRowsFieldSize(2)]);
subjectIDColHeaderLabelPos=round([subjectIDColHeaderLabelRelPos.*figSize subjectIDColHeaderLabelSize(1)*figSize(1) subjectIDColHeaderLabelSize(2)]);
subjectIDColHeaderFieldPos=round([subjectIDColHeaderFieldRelPos.*figSize subjectIDColHeaderFieldSize(1)*figSize(1) subjectIDColHeaderFieldSize(2)]);
trialIDColHeaderLabelPos=round([trialIDColHeaderLabelRelPos.*figSize trialIDColHeaderLabelSize(1)*figSize(1) trialIDColHeaderLabelSize(2)]);
trialIDColHeaderFieldPos=round([trialIDColHeaderFieldRelPos.*figSize trialIDColHeaderFieldSize(1)*figSize(1) trialIDColHeaderFieldSize(2)]);
trialIDFormatLabelPos=round([trialIDFormatLabelRelPos.*figSize trialIDFormatLabelSize(1)*figSize(1) trialIDFormatLabelSize(2)]);
trialIDFormatFieldPos=round([trialIDFormatFieldRelPos.*figSize trialIDFormatFieldSize(1)*figSize(1) trialIDFormatFieldSize(2)]);
targetTrialIDFormatLabelPos=round([targetTrialIDFormatLabelRelPos.*figSize targetTrialIDFormatLabelSize(1)*figSize(1) targetTrialIDFormatLabelSize(2)]);
targetTrialIDFormatFieldPos=round([targetTrialIDFormatFieldRelPos.*figSize targetTrialIDFormatFieldSize(1)*figSize(1) targetTrialIDFormatFieldSize(2)]);
saveAllButtonPos=round([saveAllButtonRelPos.*figSize saveAllButtonSize(1)*figSize(1) saveAllButtonSize(2)]);
selectDataPanelPos=round([selectDataPanelRelPos.*figSize selectDataPanelSize(1)*figSize(1) selectDataPanelSize(2)]);
dataTypeImportMethodFieldPos=round([dataTypeImportMethodFieldRelPos.*figSize dataTypeImportMethodFieldSize(1)*figSize(1) dataTypeImportMethodFieldSize(2)]);
addDataTypeButtonPos=round([addDataTypeButtonRelPos.*figSize addDataTypeButtonSize(1)*figSize(1) addDataTypeButtonSize(2)]);
openImportFcnButtonPos=round([openImportFcnButtonRelPos.*figSize openImportFcnButtonSize(1)*figSize(1) openImportFcnButtonSize(2)]);

% Set the actual positions for each component
data.ProjectNameLabel.Position=projectNameLabelPos;
data.LogsheetPathButton.Position=logsheetNameButtonPos;
data.DataPathButton.Position=dataPathButtonPos;
data.CodePathButton.Position=codePathButtonPos;
data.ProjectNameField.Position=projectNameEditFieldPos;
data.LogsheetPathField.Position=logsheetNameEditFieldPos;
data.DataPathField.Position=dataPathEditFieldPos;
data.CodePathField.Position=codePathEditFieldPos;
data.OpenImportMetadataButton.Position=openImportMetadataButtonPos;
data.OpenSpecifyTrialsButton.Position=openSpecifyTrialsButtonPos;
data.SwitchProjectsDropDown.Position=projectDropDownPos;
data.RunImportButton.Position=runImportButtonPos;
data.RedoImportCheckBox.Position=redoImportCheckboxPos;
% data.UpdateMetadataCheckBox.Position=updateMetadataCheckBoxPos;
data.DataTypeImportSettingsDropDown.Position=dataTypeImportSettingsDropDownPos;
data.LogsheetLabel.Position=logsheetLabelPos;
data.NumHeaderRowsLabel.Position=numHeaderRowsLabelPos;
data.NumHeaderRowsField.Position=numHeaderRowsFieldPos;
data.SubjectIDColHeaderLabel.Position=subjectIDColHeaderLabelPos;
data.SubjectIDColHeaderField.Position=subjectIDColHeaderFieldPos;
data.TrialIDColHeaderLabel.Position=trialIDColHeaderLabelPos;
data.TrialIDColHeaderField.Position=trialIDColHeaderFieldPos;
data.TrialIDFormatLabel.Position=trialIDFormatLabelPos;
data.TrialIDFormatField.Position=trialIDFormatFieldPos;
data.TargetTrialIDFormatLabel.Position=targetTrialIDFormatLabelPos;
data.TargetTrialIDFormatField.Position=targetTrialIDFormatFieldPos;
data.SaveAllButton.Position=saveAllButtonPos;
data.SelectDataPanel.Position=selectDataPanelPos;
data.DataTypeImportMethodField.Position=dataTypeImportMethodFieldPos;
data.AddDataTypeButton.Position=addDataTypeButtonPos;
data.OpenImportFcnButton.Position=openImportFcnButtonPos;

% Set the font sizes for all components that use text
data.ProjectNameLabel.FontSize=newFontSize;
data.LogsheetPathButton.FontSize=newFontSize;
data.DataPathButton.FontSize=newFontSize;
data.CodePathButton.FontSize=newFontSize;
data.ProjectNameField.FontSize=newFontSize;
data.LogsheetPathField.FontSize=newFontSize;
data.DataPathField.FontSize=newFontSize;
data.CodePathField.FontSize=newFontSize;
data.OpenImportMetadataButton.FontSize=newFontSize;
data.OpenSpecifyTrialsButton.FontSize=newFontSize;
data.SwitchProjectsDropDown.FontSize=newFontSize;
data.RunImportButton.FontSize=newFontSize;
data.RedoImportCheckBox.FontSize=newFontSize;
% data.UpdateMetadataCheckBox.FontSize=newFontSize;
data.DataTypeImportSettingsDropDown.FontSize=newFontSize;
data.LogsheetLabel.FontSize=newFontSize;
data.NumHeaderRowsLabel.FontSize=newFontSize;
data.NumHeaderRowsField.FontSize=newFontSize;
data.SubjectIDColHeaderLabel.FontSize=newFontSize;
data.SubjectIDColHeaderField.FontSize=newFontSize;
data.TrialIDColHeaderLabel.FontSize=newFontSize;
data.TrialIDColHeaderField.FontSize=newFontSize;
data.TrialIDFormatLabel.FontSize=newFontSize;
data.TrialIDFormatField.FontSize=newFontSize;
data.TargetTrialIDFormatLabel.FontSize=newFontSize;
data.TargetTrialIDFormatField.FontSize=newFontSize;
data.SaveAllButton.FontSize=newFontSize;
data.SelectDataPanel.FontSize=newFontSize;
data.DataTypeImportMethodField.FontSize=newFontSize;
data.AddDataTypeButton.FontSize=newFontSize;
data.OpenImportFcnButton.FontSize=newFontSize;

% Restore component visibility