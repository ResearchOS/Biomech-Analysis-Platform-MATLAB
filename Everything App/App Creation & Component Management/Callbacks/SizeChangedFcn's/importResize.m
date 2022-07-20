function [fontSizeRelToHeight]=importResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE IMPORT TAB

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
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(data.LogsheetPathField,'FontSize'); % Get the initial font size
        fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
        setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
    end 
else
    fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
end

% Set new font size
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end

%% Positions specified as relative to tab width & height
% All positions here are specified as relative positions
LogsheetPathButtonRelPos=[0.01 0.9];
LogsheetPathFieldRelPos=[0.08 0.9];
LogsheetLabelRelPos=[0.01 0.95];
NumHeaderRowsLabelRelPos=[0.01 0.85];
NumHeaderRowsFieldRelPos=[0.26 0.85];
SubjectIDColHeaderLabelRelPos=[0.01 0.8];
SubjectIDColHeaderFieldRelPos=[0.26 0.8];
TrialIDColHeaderDataTypeLabelRelPos=[0.01 0.75];
TrialIDColHeaderDataTypeFieldRelPos=[0.26 0.75];
TargetTrialIDColHeaderLabelRelPos=[0.01 0.7];
TargetTrialIDColHeaderFieldRelPos=[0.26 0.7];
OpenLogsheetButtonRelPos=[0.28 0.9];
LogVarsUITreeRelPos=[0.01 0.5];
DataTypeLabelRelPos=[0.22 0.65];
DataTypeDropDownRelPos=[0.31 0.65];
TrialSubjectDropDownRelPos=[0.22 0.6];
AssignVariableButtonRelPos=[0.22 0.55];
LogVarNameFieldRelPos=[0.32 0.55];
VariableNamesListboxRelPos=[0.5 0.1];
VarSearchFieldRelPos=[0.5 0.9];
RunLogImportButtonRelPos=[0.75 0.75];
CreateArgButtonRelPos=[0.75 0.9];
SpecifyTrialsUITreeRelPos=[0.01 0.01];
NewSpecifyTrialsButtonRelPos=[0.22 0.15];
RemoveSpecifyTrialsButtonRelPos=[0.22 0.1];
ImportFcnDropDownRelPos=[0.75 0.5];
CheckAllLogVarsUITreeButtonRelPos=[0.01 0.45];
UncheckAllLogVarsUITreeButtonRelPos=[0.12 0.45];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
LogsheetPathButtonSize=[0.07 compHeight];
LogsheetPathFieldSize=[0.2 compHeight];
LogsheetLabelSize=[0.2 compHeight];
NumHeaderRowsLabelSize=[0.2 compHeight];
NumHeaderRowsFieldSize=[0.08 compHeight];
SubjectIDColHeaderLabelSize=[0.25 compHeight];
SubjectIDColHeaderFieldSize=[0.2 compHeight];
TrialIDColHeaderDataTypeLabelSize=[0.25 compHeight];
TrialIDColHeaderDataTypeFieldSize=[0.2 compHeight];
TargetTrialIDColHeaderLabelSize=[0.25 compHeight];
TargetTrialIDColHeaderFieldSize=[0.2 compHeight];
OpenLogsheetButtonSize=[0.05 compHeight];
LogVarsUITreeSize=[0.2 0.2];
DataTypeLabelSize=[0.2 compHeight];
DataTypeDropDownSize=[0.1 compHeight];
TrialSubjectDropDownSize=[0.1 compHeight];
AssignVariableButtonSize=[0.1 compHeight];
LogVarNameFieldSize=[0.1 compHeight];
VariableNamesListboxSize=[0.2 0.8];
VarSearchFieldSize=[0.2 compHeight];
RunLogImportButtonSize=[0.2 compHeight];
CreateArgButtonSize=[0.2 compHeight];
SpecifyTrialsUITreeSize=[0.2 0.2];
NewSpecifyTrialsButtonSize=[0.08 compHeight];
RemoveSpecifyTrialsButtonSize=[0.08 compHeight];
ImportFcnDropDownSize=[0.2 compHeight];
CheckAllLogVarsUITreeButtonSize=[0.1 compHeight];
UncheckAllLogVarsUITreeButtonSize=[0.1 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
LogsheetPathButtonPos=round([LogsheetPathButtonRelPos.*figSize LogsheetPathButtonSize(1)*figSize(1) LogsheetPathButtonSize(2)]);
LogsheetPathFieldPos=round([LogsheetPathFieldRelPos.*figSize LogsheetPathFieldSize(1)*figSize(1) LogsheetPathFieldSize(2)]);
LogsheetLabelPos=round([LogsheetLabelRelPos.*figSize LogsheetLabelSize(1)*figSize(1) LogsheetLabelSize(2)]);
NumHeaderRowsLabelPos=round([NumHeaderRowsLabelRelPos.*figSize NumHeaderRowsLabelSize(1)*figSize(1) NumHeaderRowsLabelSize(2)]);
NumHeaderRowsFieldPos=round([NumHeaderRowsFieldRelPos.*figSize NumHeaderRowsFieldSize(1)*figSize(1) NumHeaderRowsFieldSize(2)]);
SubjectIDColHeaderLabelPos=round([SubjectIDColHeaderLabelRelPos.*figSize SubjectIDColHeaderLabelSize(1)*figSize(1) SubjectIDColHeaderLabelSize(2)]);
SubjectIDColHeaderFieldPos=round([SubjectIDColHeaderFieldRelPos.*figSize SubjectIDColHeaderFieldSize(1)*figSize(1) SubjectIDColHeaderFieldSize(2)]);
TrialIDColHeaderDataTypeLabelPos=round([TrialIDColHeaderDataTypeLabelRelPos.*figSize TrialIDColHeaderDataTypeLabelSize(1)*figSize(1) TrialIDColHeaderDataTypeLabelSize(2)]);
TrialIDColHeaderDataTypeFieldPos=round([TrialIDColHeaderDataTypeFieldRelPos.*figSize TrialIDColHeaderDataTypeFieldSize(1)*figSize(1) TrialIDColHeaderDataTypeFieldSize(2)]);
TargetTrialIDColHeaderLabelPos=round([TargetTrialIDColHeaderLabelRelPos.*figSize TargetTrialIDColHeaderLabelSize(1)*figSize(1) TargetTrialIDColHeaderLabelSize(2)]);
TargetTrialIDColHeaderFieldPos=round([TargetTrialIDColHeaderFieldRelPos.*figSize TargetTrialIDColHeaderFieldSize(1)*figSize(1) TargetTrialIDColHeaderFieldSize(2)]);
OpenLogsheetButtonPos=round([OpenLogsheetButtonRelPos.*figSize OpenLogsheetButtonSize(1)*figSize(1) OpenLogsheetButtonSize(2)]);
LogVarsUITreePos=round([LogVarsUITreeRelPos.*figSize LogVarsUITreeSize.*figSize]);
DataTypeLabelPos=round([DataTypeLabelRelPos.*figSize DataTypeLabelSize(1)*figSize(1) DataTypeLabelSize(2)]);
DataTypeDropDownPos=round([DataTypeDropDownRelPos.*figSize DataTypeDropDownSize(1)*figSize(1) DataTypeDropDownSize(2)]);
TrialSubjectDropDownPos=round([TrialSubjectDropDownRelPos.*figSize TrialSubjectDropDownSize(1)*figSize(1) TrialSubjectDropDownSize(2)]);
AssignVariableButtonPos=round([AssignVariableButtonRelPos.*figSize AssignVariableButtonSize(1)*figSize(1) AssignVariableButtonSize(2)]);
LogVarNameFieldPos=round([LogVarNameFieldRelPos.*figSize LogVarNameFieldSize(1)*figSize(1) LogVarNameFieldSize(2)]);
VariableNamesListboxPos=round([VariableNamesListboxRelPos.*figSize VariableNamesListboxSize.*figSize]);
VarSearchFieldPos=round([VarSearchFieldRelPos.*figSize VarSearchFieldSize(1)*figSize(1) VarSearchFieldSize(2)]);
RunLogImportButtonPos=round([RunLogImportButtonRelPos.*figSize RunLogImportButtonSize(1)*figSize(1) RunLogImportButtonSize(2)]);
CreateArgButtonPos=round([CreateArgButtonRelPos.*figSize CreateArgButtonSize(1)*figSize(1) CreateArgButtonSize(2)]);
SpecifyTrialsUITreePos=round([SpecifyTrialsUITreeRelPos.*figSize SpecifyTrialsUITreeSize.*figSize]);
NewSpecifyTrialsButtonPos=round([NewSpecifyTrialsButtonRelPos.*figSize NewSpecifyTrialsButtonSize(1)*figSize(1) NewSpecifyTrialsButtonSize(2)]);
RemoveSpecifyTrialsButtonPos=round([RemoveSpecifyTrialsButtonRelPos.*figSize RemoveSpecifyTrialsButtonSize(1)*figSize(1) RemoveSpecifyTrialsButtonSize(2)]);
ImportFcnDropDownPos=round([ImportFcnDropDownRelPos.*figSize ImportFcnDropDownSize(1)*figSize(1) ImportFcnDropDownSize(2)]);
CheckAllLogVarsUITreeButtonPos=round([CheckAllLogVarsUITreeButtonRelPos.*figSize CheckAllLogVarsUITreeButtonSize(1)*figSize(1) CheckAllLogVarsUITreeButtonSize(2)]);
UncheckAllLogVarsUITreeButtonPos=round([UncheckAllLogVarsUITreeButtonRelPos.*figSize UncheckAllLogVarsUITreeButtonSize(1)*figSize(1) UncheckAllLogVarsUITreeButtonSize(2)]);

data.LogsheetPathButton.Position=LogsheetPathButtonPos;
data.LogsheetPathField.Position=LogsheetPathFieldPos;
data.LogsheetLabel.Position=LogsheetLabelPos;
data.NumHeaderRowsLabel.Position=NumHeaderRowsLabelPos;
data.NumHeaderRowsField.Position=NumHeaderRowsFieldPos;
data.SubjectIDColHeaderLabel.Position=SubjectIDColHeaderLabelPos;
data.SubjectIDColHeaderField.Position=SubjectIDColHeaderFieldPos;
data.TrialIDColHeaderDataTypeLabel.Position=TrialIDColHeaderDataTypeLabelPos;
data.TrialIDColHeaderDataTypeField.Position=TrialIDColHeaderDataTypeFieldPos;
data.TargetTrialIDColHeaderLabel.Position=TargetTrialIDColHeaderLabelPos;
data.TargetTrialIDColHeaderField.Position=TargetTrialIDColHeaderFieldPos;
data.OpenLogsheetButton.Position=OpenLogsheetButtonPos;
data.LogVarsUITree.Position=LogVarsUITreePos;
data.DataTypeLabel.Position=DataTypeLabelPos;
data.DataTypeDropDown.Position=DataTypeDropDownPos;
data.TrialSubjectDropDown.Position=TrialSubjectDropDownPos;
data.AssignVariableButton.Position=AssignVariableButtonPos;
data.LogVarNameField.Position=LogVarNameFieldPos;
data.VariableNamesListbox.Position=VariableNamesListboxPos;
data.VarSearchField.Position=VarSearchFieldPos;
data.RunLogImportButton.Position=RunLogImportButtonPos;
data.CreateArgButton.Position=CreateArgButtonPos;
data.SpecifyTrialsUITree.Position=SpecifyTrialsUITreePos;
data.NewSpecifyTrialsButton.Position=NewSpecifyTrialsButtonPos;
data.RemoveSpecifyTrialsButton.Position=RemoveSpecifyTrialsButtonPos;
data.ImportFcnDropDown.Position=ImportFcnDropDownPos;
data.CheckAllLogVarsUITreeButton.Position=CheckAllLogVarsUITreeButtonPos;
data.UncheckAllLogVarsUITreeButton.Position=UncheckAllLogVarsUITreeButtonPos;

data.LogsheetPathButton.FontSize=newFontSize;
data.LogsheetPathField.FontSize=newFontSize;
data.LogsheetLabel.FontSize=newFontSize;
data.NumHeaderRowsLabel.FontSize=newFontSize;
data.NumHeaderRowsField.FontSize=newFontSize;
data.SubjectIDColHeaderLabel.FontSize=newFontSize;
data.SubjectIDColHeaderField.FontSize=newFontSize;
data.TrialIDColHeaderDataTypeLabel.FontSize=newFontSize;
data.TrialIDColHeaderDataTypeField.FontSize=newFontSize;
data.TargetTrialIDColHeaderLabel.FontSize=newFontSize;
data.TargetTrialIDColHeaderField.FontSize=newFontSize;
data.OpenLogsheetButton.FontSize=newFontSize;
data.LogVarsUITree.FontSize=newFontSize;
data.DataTypeLabel.FontSize=newFontSize;
data.DataTypeDropDown.FontSize=newFontSize;
data.TrialSubjectDropDown.FontSize=newFontSize;
data.AssignVariableButton.FontSize=newFontSize;
data.LogVarNameField.FontSize=newFontSize;
data.VariableNamesListbox.FontSize=newFontSize;
data.VarSearchField.FontSize=newFontSize;
data.RunLogImportButton.FontSize=newFontSize;
data.CreateArgButton.FontSize=newFontSize;
data.SpecifyTrialsUITree.FontSize=newFontSize;
data.NewSpecifyTrialsButton.FontSize=newFontSize;
data.RemoveSpecifyTrialsButton.FontSize=newFontSize;
data.ImportFcnDropDown.FontSize=newFontSize;
data.CheckAllLogVarsUITreeButton.FontSize=newFontSize;
data.UncheckAllLogVarsUITreeButton.FontSize=newFontSize;