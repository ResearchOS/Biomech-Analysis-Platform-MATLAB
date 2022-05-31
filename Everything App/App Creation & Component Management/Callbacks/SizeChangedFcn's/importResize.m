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
ProjectNameLabelRelPos=[0.01 0.95];
LogsheetPathButtonRelPos=[0.01 0.8];
DataPathButtonRelPos=[0.01 0.85];
CodePathButtonRelPos=[0.01 0.9];
AddProjectButtonRelPos=[0.37 0.95];
LogsheetPathFieldRelPos=[0.17 0.8];
DataPathFieldRelPos=[0.17 0.85];
CodePathFieldRelPos=[0.17 0.9];
OpenSpecifyTrialsButtonRelPos=[0.53 0.02];
SwitchProjectsDropDownRelPos=[0.17 0.95];
RunImportButtonRelPos=[0.75 0.02];
LogsheetLabelRelPos=[0.5 0.95];
NumHeaderRowsLabelRelPos=[0.6 0.95];
NumHeaderRowsFieldRelPos=[0.76 0.95];
SubjectIDColHeaderLabelRelPos=[0.5 0.9];
SubjectIDColHeaderFieldRelPos=[0.76 0.9];
TrialIDColHeaderDataTypeLabelRelPos=[0.5 0.85];
TrialIDColHeaderDataTypeFieldRelPos=[0.76 0.85];
TargetTrialIDColHeaderLabelRelPos=[0.5 0.8];
TargetTrialIDColHeaderFieldRelPos=[0.76 0.8];
ArchiveImportFcnButtonRelPos=[0.01 0.55];
NewImportFcnButtonRelPos=[0.01 0.6];
OpenLogsheetButtonRelPos=[0.37 0.8];
OpenDataPathButtonRelPos=[0.37 0.85];
OpenCodePathButtonRelPos=[0.37 0.9];
ArchiveProjectButtonRelPos=[0.43 0.95];
FunctionsUITreeLabelRelPos=[0.12 0.75];
ArgumentsUITreeLabelRelPos=[0.34 0.75];
FunctionsSearchBarEditFieldRelPos=[0.07 0.7];
ArgumentsSearchBarEditFieldRelPos=[0.3 0.7];
FunctionsUITreeRelPos=[0.07 0.02];
ArgumentsUITreeRelPos=[0.3 0.02];
GroupFunctionDescriptionTextAreaLabelRelPos=[0.55 0.75];
GroupFunctionDescriptionTextAreaRelPos=[0.55 0.45];
UnarchiveImportFcnButtonRelPos=[0.01 0.55];
ArgumentDescriptionTextAreaLabelRelPos=[0.55 0.4];
ArgumentDescriptionTextAreaRelPos=[0.55 0.1];
UnarchiveProjectButtonRelPos=[0.43 0.9];
AddArgumentButtonRelPos=[0.01 0.3];
ArchiveArgumentButtonRelPos=[0.01 0.25];
UnarchiveArgumentButtonRelPos=[0.01 0.35];
AddDataTypeButtonRelPos=[0.01 0.75];
ArchiveDataTypeButtonRelPos=[0.01 0.7];
AddInputArgumentButtonRelPos=[0.01 0.15];
AddOutputArgumentButtonRelPos=[0.01 0.1];
RemoveArgumentButtonRelPos=[0.01 0.05];
FunctionToDataTypeButtonRelPos=[0.01 0.45];
FunctionFromDataTypeButtonRelPos=[0.01 0.4];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
ProjectNameLabelSize=[0.15 compHeight];
LogsheetPathButtonSize=[0.15 compHeight];
DataPathButtonSize=[0.15 compHeight];
CodePathButtonSize=[0.15 compHeight];
AddProjectButtonSize=[0.05 compHeight];
LogsheetPathFieldSize=[0.2 compHeight];
DataPathFieldSize=[0.2 compHeight];
CodePathFieldSize=[0.2 compHeight];
OpenSpecifyTrialsButtonSize=[0.2 compHeight];
SwitchProjectsDropDownSize=[0.2 compHeight];
RunImportButtonSize=[0.2 compHeight];
LogsheetLabelSize=[0.2 compHeight];
NumHeaderRowsLabelSize=[0.2 compHeight];
NumHeaderRowsFieldSize=[0.08 compHeight];
SubjectIDColHeaderLabelSize=[0.25 compHeight];
SubjectIDColHeaderFieldSize=[0.2 compHeight];
TrialIDColHeaderDataTypeLabelSize=[0.25 compHeight];
TrialIDColHeaderDataTypeFieldSize=[0.2 compHeight];
TargetTrialIDColHeaderLabelSize=[0.25 compHeight];
TargetTrialIDColHeaderFieldSize=[0.2 compHeight];
ArchiveImportFcnButtonSize=[0.06 compHeight];
NewImportFcnButtonSize=[0.06 compHeight];
OpenLogsheetButtonSize=[0.05 compHeight];
OpenDataPathButtonSize=[0.05 compHeight];
OpenCodePathButtonSize=[0.05 compHeight];
ArchiveProjectButtonSize=[0.06 compHeight];
FunctionsUITreeLabelSize=[0.2 compHeight];
ArgumentsUITreeLabelSize=[0.2 compHeight];
FunctionsSearchBarEditFieldSize=[0.2 compHeight];
ArgumentsSearchBarEditFieldSize=[0.2 compHeight];
FunctionsUITreeSize=[0.2 0.68*figSize(2)];
ArgumentsUITreeSize=[0.2 0.68*figSize(2)];
GroupFunctionDescriptionTextAreaLabelSize=[0.3 compHeight];
GroupFunctionDescriptionTextAreaSize=[0.4 0.3*figSize(2)];
UnarchiveImportFcnButtonSize=[0.06 compHeight];
ArgumentDescriptionTextAreaLabelSize=[0.3 compHeight];
ArgumentDescriptionTextAreaSize=[0.4 0.3*figSize(2)];
UnarchiveProjectButtonSize=[0.06 compHeight];
AddArgumentButtonSize=[0.06 compHeight];
ArchiveArgumentButtonSize=[0.06 compHeight];
UnarchiveArgumentButtonSize=[0.06 compHeight];
AddDataTypeButtonSize=[0.06 compHeight];
ArchiveDataTypeButtonSize=[0.06 compHeight];
AddInputArgumentButtonSize=[0.06 compHeight];
AddOutputArgumentButtonSize=[0.06 compHeight];
RemoveArgumentButtonSize=[0.06 compHeight];
FunctionToDataTypeButtonSize=[0.06 compHeight];
FunctionFromDataTypeButtonSize=[0.06 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
ProjectNameLabelPos=round([ProjectNameLabelRelPos.*figSize ProjectNameLabelSize(1)*figSize(1) ProjectNameLabelSize(2)]);
LogsheetPathButtonPos=round([LogsheetPathButtonRelPos.*figSize LogsheetPathButtonSize(1)*figSize(1) LogsheetPathButtonSize(2)]);
DataPathButtonPos=round([DataPathButtonRelPos.*figSize DataPathButtonSize(1)*figSize(1) DataPathButtonSize(2)]);
CodePathButtonPos=round([CodePathButtonRelPos.*figSize CodePathButtonSize(1)*figSize(1) CodePathButtonSize(2)]);
AddProjectButtonPos=round([AddProjectButtonRelPos.*figSize AddProjectButtonSize(1)*figSize(1) AddProjectButtonSize(2)]);
LogsheetPathFieldPos=round([LogsheetPathFieldRelPos.*figSize LogsheetPathFieldSize(1)*figSize(1) LogsheetPathFieldSize(2)]);
DataPathFieldPos=round([DataPathFieldRelPos.*figSize DataPathFieldSize(1)*figSize(1) DataPathFieldSize(2)]);
CodePathFieldPos=round([CodePathFieldRelPos.*figSize CodePathFieldSize(1)*figSize(1) CodePathFieldSize(2)]);
OpenSpecifyTrialsButtonPos=round([OpenSpecifyTrialsButtonRelPos.*figSize OpenSpecifyTrialsButtonSize(1)*figSize(1) OpenSpecifyTrialsButtonSize(2)]);
SwitchProjectsDropDownPos=round([SwitchProjectsDropDownRelPos.*figSize SwitchProjectsDropDownSize(1)*figSize(1) SwitchProjectsDropDownSize(2)]);
RunImportButtonPos=round([RunImportButtonRelPos.*figSize RunImportButtonSize(1)*figSize(1) RunImportButtonSize(2)]);
LogsheetLabelPos=round([LogsheetLabelRelPos.*figSize LogsheetLabelSize(1)*figSize(1) LogsheetLabelSize(2)]);
NumHeaderRowsLabelPos=round([NumHeaderRowsLabelRelPos.*figSize NumHeaderRowsLabelSize(1)*figSize(1) NumHeaderRowsLabelSize(2)]);
NumHeaderRowsFieldPos=round([NumHeaderRowsFieldRelPos.*figSize NumHeaderRowsFieldSize(1)*figSize(1) NumHeaderRowsFieldSize(2)]);
SubjectIDColHeaderLabelPos=round([SubjectIDColHeaderLabelRelPos.*figSize SubjectIDColHeaderLabelSize(1)*figSize(1) SubjectIDColHeaderLabelSize(2)]);
SubjectIDColHeaderFieldPos=round([SubjectIDColHeaderFieldRelPos.*figSize SubjectIDColHeaderFieldSize(1)*figSize(1) SubjectIDColHeaderFieldSize(2)]);
TrialIDColHeaderDataTypeLabelPos=round([TrialIDColHeaderDataTypeLabelRelPos.*figSize TrialIDColHeaderDataTypeLabelSize(1)*figSize(1) TrialIDColHeaderDataTypeLabelSize(2)]);
TrialIDColHeaderDataTypeFieldPos=round([TrialIDColHeaderDataTypeFieldRelPos.*figSize TrialIDColHeaderDataTypeFieldSize(1)*figSize(1) TrialIDColHeaderDataTypeFieldSize(2)]);
TargetTrialIDColHeaderLabelPos=round([TargetTrialIDColHeaderLabelRelPos.*figSize TargetTrialIDColHeaderLabelSize(1)*figSize(1) TargetTrialIDColHeaderLabelSize(2)]);
TargetTrialIDColHeaderFieldPos=round([TargetTrialIDColHeaderFieldRelPos.*figSize TargetTrialIDColHeaderFieldSize(1)*figSize(1) TargetTrialIDColHeaderFieldSize(2)]);
ArchiveImportFcnButtonPos=round([ArchiveImportFcnButtonRelPos.*figSize ArchiveImportFcnButtonSize(1)*figSize(1) ArchiveImportFcnButtonSize(2)]);
NewImportFcnButtonPos=round([NewImportFcnButtonRelPos.*figSize NewImportFcnButtonSize(1)*figSize(1) NewImportFcnButtonSize(2)]);
OpenLogsheetButtonPos=round([OpenLogsheetButtonRelPos.*figSize OpenLogsheetButtonSize(1)*figSize(1) OpenLogsheetButtonSize(2)]);
OpenDataPathButtonPos=round([OpenDataPathButtonRelPos.*figSize OpenDataPathButtonSize(1)*figSize(1) OpenDataPathButtonSize(2)]);
OpenCodePathButtonPos=round([OpenCodePathButtonRelPos.*figSize OpenCodePathButtonSize(1)*figSize(1) OpenCodePathButtonSize(2)]);
ArchiveProjectButtonPos=round([ArchiveProjectButtonRelPos.*figSize ArchiveProjectButtonSize(1)*figSize(1) ArchiveProjectButtonSize(2)]);
FunctionsUITreeLabelPos=round([FunctionsUITreeLabelRelPos.*figSize FunctionsUITreeLabelSize(1)*figSize(1) FunctionsUITreeLabelSize(2)]);
ArgumentsUITreeLabelPos=round([ArgumentsUITreeLabelRelPos.*figSize ArgumentsUITreeLabelSize(1)*figSize(1) ArgumentsUITreeLabelSize(2)]);
FunctionsSearchBarEditFieldPos=round([FunctionsSearchBarEditFieldRelPos.*figSize FunctionsSearchBarEditFieldSize(1)*figSize(1) FunctionsSearchBarEditFieldSize(2)]);
ArgumentsSearchBarEditFieldPos=round([ArgumentsSearchBarEditFieldRelPos.*figSize ArgumentsSearchBarEditFieldSize(1)*figSize(1) ArgumentsSearchBarEditFieldSize(2)]);
FunctionsUITreePos=round([FunctionsUITreeRelPos.*figSize FunctionsUITreeSize(1)*figSize(1) FunctionsUITreeSize(2)]);
ArgumentsUITreePos=round([ArgumentsUITreeRelPos.*figSize ArgumentsUITreeSize(1)*figSize(1) ArgumentsUITreeSize(2)]);
GroupFunctionDescriptionTextAreaLabelPos=round([GroupFunctionDescriptionTextAreaLabelRelPos.*figSize GroupFunctionDescriptionTextAreaLabelSize(1)*figSize(1) GroupFunctionDescriptionTextAreaLabelSize(2)]);
GroupFunctionDescriptionTextAreaPos=round([GroupFunctionDescriptionTextAreaRelPos.*figSize GroupFunctionDescriptionTextAreaSize(1)*figSize(1) GroupFunctionDescriptionTextAreaSize(2)]);
UnarchiveImportFcnButtonPos=round([UnarchiveImportFcnButtonRelPos.*figSize UnarchiveImportFcnButtonSize(1)*figSize(1) UnarchiveImportFcnButtonSize(2)]);
ArgumentDescriptionTextAreaLabelPos=round([ArgumentDescriptionTextAreaLabelRelPos.*figSize ArgumentDescriptionTextAreaLabelSize(1)*figSize(1) ArgumentDescriptionTextAreaLabelSize(2)]);
ArgumentDescriptionTextAreaPos=round([ArgumentDescriptionTextAreaRelPos.*figSize ArgumentDescriptionTextAreaSize(1)*figSize(1) ArgumentDescriptionTextAreaSize(2)]);
UnarchiveProjectButtonPos=round([UnarchiveProjectButtonRelPos.*figSize UnarchiveProjectButtonSize(1)*figSize(1) UnarchiveProjectButtonSize(2)]);
AddArgumentButtonPos=round([AddArgumentButtonRelPos.*figSize AddArgumentButtonSize(1)*figSize(1) AddArgumentButtonSize(2)]);
ArchiveArgumentButtonPos=round([ArchiveArgumentButtonRelPos.*figSize ArchiveArgumentButtonSize(1)*figSize(1) ArchiveArgumentButtonSize(2)]);
UnarchiveArgumentButtonPos=round([UnarchiveArgumentButtonRelPos.*figSize UnarchiveArgumentButtonSize(1)*figSize(1) UnarchiveArgumentButtonSize(2)]);
AddDataTypeButtonPos=round([AddDataTypeButtonRelPos.*figSize AddDataTypeButtonSize(1)*figSize(1) AddDataTypeButtonSize(2)]);
ArchiveDataTypeButtonPos=round([ArchiveDataTypeButtonRelPos.*figSize ArchiveDataTypeButtonSize(1)*figSize(1) ArchiveDataTypeButtonSize(2)]);
AddInputArgumentButtonPos=round([AddInputArgumentButtonRelPos.*figSize AddInputArgumentButtonSize(1)*figSize(1) AddInputArgumentButtonSize(2)]);
AddOutputArgumentButtonPos=round([AddOutputArgumentButtonRelPos.*figSize AddOutputArgumentButtonSize(1)*figSize(1) AddOutputArgumentButtonSize(2)]);
RemoveArgumentButtonPos=round([RemoveArgumentButtonRelPos.*figSize RemoveArgumentButtonSize(1)*figSize(1) RemoveArgumentButtonSize(2)]);
FunctionToDataTypeButtonPos=round([FunctionToDataTypeButtonRelPos.*figSize FunctionToDataTypeButtonSize(1)*figSize(1) FunctionToDataTypeButtonSize(2)]);
FunctionFromDataTypeButtonPos=round([FunctionFromDataTypeButtonRelPos.*figSize FunctionFromDataTypeButtonSize(1)*figSize(1) FunctionFromDataTypeButtonSize(2)]);

data.ProjectNameLabel.Position=ProjectNameLabelPos;
data.LogsheetPathButton.Position=LogsheetPathButtonPos;
data.DataPathButton.Position=DataPathButtonPos;
data.CodePathButton.Position=CodePathButtonPos;
data.AddProjectButton.Position=AddProjectButtonPos;
data.LogsheetPathField.Position=LogsheetPathFieldPos;
data.DataPathField.Position=DataPathFieldPos;
data.CodePathField.Position=CodePathFieldPos;
data.OpenSpecifyTrialsButton.Position=OpenSpecifyTrialsButtonPos;
data.SwitchProjectsDropDown.Position=SwitchProjectsDropDownPos;
data.RunImportButton.Position=RunImportButtonPos;
data.LogsheetLabel.Position=LogsheetLabelPos;
data.NumHeaderRowsLabel.Position=NumHeaderRowsLabelPos;
data.NumHeaderRowsField.Position=NumHeaderRowsFieldPos;
data.SubjectIDColHeaderLabel.Position=SubjectIDColHeaderLabelPos;
data.SubjectIDColHeaderField.Position=SubjectIDColHeaderFieldPos;
data.TrialIDColHeaderDataTypeLabel.Position=TrialIDColHeaderDataTypeLabelPos;
data.TrialIDColHeaderDataTypeField.Position=TrialIDColHeaderDataTypeFieldPos;
data.TargetTrialIDColHeaderLabel.Position=TargetTrialIDColHeaderLabelPos;
data.TargetTrialIDColHeaderField.Position=TargetTrialIDColHeaderFieldPos;
data.ArchiveImportFcnButton.Position=ArchiveImportFcnButtonPos;
data.NewImportFcnButton.Position=NewImportFcnButtonPos;
data.OpenLogsheetButton.Position=OpenLogsheetButtonPos;
data.OpenDataPathButton.Position=OpenDataPathButtonPos;
data.OpenCodePathButton.Position=OpenCodePathButtonPos;
data.ArchiveProjectButton.Position=ArchiveProjectButtonPos;
data.FunctionsUITreeLabel.Position=FunctionsUITreeLabelPos;
data.ArgumentsUITreeLabel.Position=ArgumentsUITreeLabelPos;
data.FunctionsSearchBarEditField.Position=FunctionsSearchBarEditFieldPos;
data.ArgumentsSearchBarEditField.Position=ArgumentsSearchBarEditFieldPos;
data.FunctionsUITree.Position=FunctionsUITreePos;
data.ArgumentsUITree.Position=ArgumentsUITreePos;
data.GroupFunctionDescriptionTextAreaLabel.Position=GroupFunctionDescriptionTextAreaLabelPos;
data.GroupFunctionDescriptionTextArea.Position=GroupFunctionDescriptionTextAreaPos;
data.UnarchiveImportFcnButton.Position=UnarchiveImportFcnButtonPos;
data.ArgumentDescriptionTextAreaLabel.Position=ArgumentDescriptionTextAreaLabelPos;
data.ArgumentDescriptionTextArea.Position=ArgumentDescriptionTextAreaPos;
data.UnarchiveProjectButton.Position=UnarchiveProjectButtonPos;
data.AddArgumentButton.Position=AddArgumentButtonPos;
data.ArchiveArgumentButton.Position=ArchiveArgumentButtonPos;
data.UnarchiveArgumentButton.Position=UnarchiveArgumentButtonPos;
data.AddDataTypeButton.Position=AddDataTypeButtonPos;
data.ArchiveDataTypeButton.Position=ArchiveDataTypeButtonPos;
data.AddInputArgumentButton.Position=AddInputArgumentButtonPos;
data.AddOutputArgumentButton.Position=AddOutputArgumentButtonPos;
data.RemoveArgumentButton.Position=RemoveArgumentButtonPos;
data.FunctionToDataTypeButton.Position=FunctionToDataTypeButtonPos;
data.FunctionFromDataTypeButton.Position=FunctionFromDataTypeButtonPos;

data.ProjectNameLabel.FontSize=newFontSize;
data.LogsheetPathButton.FontSize=newFontSize;
data.DataPathButton.FontSize=newFontSize;
data.CodePathButton.FontSize=newFontSize;
data.AddProjectButton.FontSize=newFontSize;
data.LogsheetPathField.FontSize=newFontSize;
data.DataPathField.FontSize=newFontSize;
data.CodePathField.FontSize=newFontSize;
data.OpenSpecifyTrialsButton.FontSize=newFontSize;
data.SwitchProjectsDropDown.FontSize=newFontSize;
data.RunImportButton.FontSize=newFontSize;
data.LogsheetLabel.FontSize=newFontSize;
data.NumHeaderRowsLabel.FontSize=newFontSize;
data.NumHeaderRowsField.FontSize=newFontSize;
data.SubjectIDColHeaderLabel.FontSize=newFontSize;
data.SubjectIDColHeaderField.FontSize=newFontSize;
data.TrialIDColHeaderDataTypeLabel.FontSize=newFontSize;
data.TrialIDColHeaderDataTypeField.FontSize=newFontSize;
data.TargetTrialIDColHeaderLabel.FontSize=newFontSize;
data.TargetTrialIDColHeaderField.FontSize=newFontSize;
data.ArchiveImportFcnButton.FontSize=newFontSize;
data.NewImportFcnButton.FontSize=newFontSize;
data.OpenLogsheetButton.FontSize=newFontSize;
data.OpenDataPathButton.FontSize=newFontSize;
data.OpenCodePathButton.FontSize=newFontSize;
data.ArchiveProjectButton.FontSize=newFontSize;
data.FunctionsUITreeLabel.FontSize=newFontSize;
data.ArgumentsUITreeLabel.FontSize=newFontSize;
data.FunctionsSearchBarEditField.FontSize=newFontSize;
data.ArgumentsSearchBarEditField.FontSize=newFontSize;
data.FunctionsUITree.FontSize=newFontSize;
data.ArgumentsUITree.FontSize=newFontSize;
data.GroupFunctionDescriptionTextAreaLabel.FontSize=newFontSize;
data.GroupFunctionDescriptionTextArea.FontSize=newFontSize;
data.UnarchiveImportFcnButton.FontSize=newFontSize;
data.ArgumentDescriptionTextAreaLabel.FontSize=newFontSize;
data.ArgumentDescriptionTextArea.FontSize=newFontSize;
data.UnarchiveProjectButton.FontSize=newFontSize;
data.AddArgumentButton.FontSize=newFontSize;
data.ArchiveArgumentButton.FontSize=newFontSize;
data.UnarchiveArgumentButton.FontSize=newFontSize;
data.AddDataTypeButton.FontSize=newFontSize;
data.ArchiveDataTypeButton.FontSize=newFontSize;
data.AddInputArgumentButton.FontSize=newFontSize;
data.AddOutputArgumentButton.FontSize=newFontSize;
data.RemoveArgumentButton.FontSize=newFontSize;
data.FunctionToDataTypeButton.FontSize=newFontSize;
data.FunctionFromDataTypeButton.FontSize=newFontSize;