function []=processResize(src, event)

%% RESIZE THE COMPONENTS WITHIN THE PROCESS TAB.

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
% if isequal(ancSize,defaultPos(3:4))
%     set(gca,'Position',[defaultPos(1:2) defaultPos(3)*2 defaultPos(4)]);
%     newDefaultPos=defaultPos(3:4);
%     newDefaultPos(1)=newDefaultPos(1)*2;
% end
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(data.SwitchAnalysisDropDown,'FontSize'); % Get the initial font size
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
AnalysisLabelRelPos=[0.01 0.95];
SwitchAnalysisDropDownRelPos=[0.1 0.95];
NewAnalysisButtonRelPos=[0.3 0.95];
ArchiveAnalysisButtonRelPos=[0.33 0.95];
FunctionsUITreeLabelRelPos=[0.12 0.9];
ArgumentsUITreeLabelRelPos=[0.3 0.9];
FunctionsSearchBarEditFieldRelPos=[0.1 0.85];
ArgumentsSearchBarEditFieldRelPos=[0.3 0.85];
FunctionsUITreeRelPos=[0.1 0.02];
ArgumentsUITreeRelPos=[0.3 0.02];
NewGroupButtonRelPos=[0.01 0.9];
ArchiveGroupButtonRelPos=[0.05 0.9];
NewFunctionButtonRelPos=[0.01 0.85];
ArchiveFunctionButtonRelPos=[0.05 0.85];
FunctionToGroupButtonRelPos=[0.01 0.8];
FunctionFromGroupButtonRelPos=[0.05 0.8];
ReorderGroupsButtonRelPos=[0.01 0.75];
ReorderFunctionsButtonRelPos=[0.01 0.7];
NewArgumentButtonRelPos=[0.01 0.6];
ArchiveArgumentButtonRelPos=[0.05 0.6];
AddInputArgumentButtonRelPos=[0.01 0.5];
AddOutputArgumentButtonRelPos=[0.05 0.5];
RemoveArgumentButtonRelPos=[0.03 0.45];
ManualArgumentCheckboxRelPos=[0.01 0.35];
EditNameLabelRelPos=[0.01 0.3];
EditNameEditFieldRelPos=[0.01 0.25];
ManualSaveArgButtonRelPos=[0.01 0.20];
ArgFcnNameLabelRelPos=[0.01 0.55];
% AnalysisDescriptionLabelRelPos=[0.5 0.95];
AnalysisDescriptionButtonRelPos=[0.4 0.95];
GenRunCodeButtonRelPos=[0.55 0.95];
ArgNameLabelRelPos=[0.5 0.4];
NameInCodeEditFieldRelPos=[0.65 0.4];
ArgLevelLabelRelPos=[0.81 0.4];
LevelDropDownRelPos=[0.85 0.4];
SubvariablesLabelRelPos=[0.5 0.9];
SubvariablesIndexEditFieldRelPos=[0.7 0.85];
GroupSpecifyTrialsLabelRelPos=[0.5 0.5];
GroupSpecifyTrialsButtonRelPos=[0.5 0.5];
FunctionSpecifyTrialsLabelRelPos=[0.5 0.5];
FunctionSpecifyTrialsButtonRelPos=[0.5 0.5];
GroupFcnDescriptionLabelRelPos=[0.5 0.7];
GroupFcnDescriptionTextAreaRelPos=[0.5 0.45];
ArgDescriptionTextAreaRelPos=[0.5 0.1];
RunGroupButtonRelPos=[0.85 0.02];
SubvariableUITreeRelPos=[0.5 0.75];
ModifySubvariablesButtonRelPos=[0.7 0.8];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
AnalysisLabelSize=[0.1 compHeight];
SwitchAnalysisDropDownSize=[0.2 compHeight];
NewAnalysisButtonSize=[0.03 compHeight];
ArchiveAnalysisButtonSize=[0.05 compHeight];
FunctionsUITreeLabelSize=[0.2 compHeight];
ArgumentsUITreeLabelSize=[0.2 compHeight];
FunctionsSearchBarEditFieldSize=[0.15 compHeight];
ArgumentsSearchBarEditFieldSize=[0.15 compHeight];
FunctionsUITreeSize=[0.15 round(0.8*figSize(2))];
ArgumentsUITreeSize=[0.15 round(0.8*figSize(2))];
NewGroupButtonSize=[0.04 compHeight];
ArchiveGroupButtonSize=[0.04 compHeight];
NewFunctionButtonSize=[0.04 compHeight];
ArchiveFunctionButtonSize=[0.04 compHeight];
FunctionToGroupButtonSize=[0.04 compHeight];
FunctionFromGroupButtonSize=[0.04 compHeight];
ReorderGroupsButtonSize=[0.09 compHeight];
ReorderFunctionsButtonSize=[0.09 compHeight];
NewArgumentButtonSize=[0.04 compHeight];
ArchiveArgumentButtonSize=[0.04 compHeight];
AddInputArgumentButtonSize=[0.04 compHeight];
AddOutputArgumentButtonSize=[0.04 compHeight];
RemoveArgumentButtonSize=[0.04 compHeight];
ManualArgumentCheckboxSize=[0.08 compHeight];
EditNameLabelSize=[0.08 compHeight];
EditNameEditFieldSize=[0.09 compHeight];
ManualSaveArgButtonSize=[0.09 compHeight];
ArgFcnNameLabelSize=[0.09 compHeight];
% AnalysisDescriptionLabelSize=[0.2 compHeight];
AnalysisDescriptionButtonSize=[0.1 compHeight];
GenRunCodeButtonSize=[0.2 compHeight];
ArgNameLabelSize=[0.2 compHeight];
NameInCodeEditFieldSize=[0.15 compHeight];
ArgLevelLabelSize=[0.7 compHeight];
LevelDropDownSize=[0.08 compHeight];
SubvariablesLabelSize=[0.2 compHeight];
SubvariablesIndexEditFieldSize=[0.2 compHeight];
GroupSpecifyTrialsLabelSize=[0.2 compHeight];
GroupSpecifyTrialsButtonSize=[0.2 compHeight];
FunctionSpecifyTrialsLabelSize=[0.2 compHeight];
FunctionSpecifyTrialsButtonSize=[0.2 compHeight];
GroupFcnDescriptionLabelSize=[0.2 compHeight];
GroupFcnDescriptionTextAreaSize=[0.45 round(0.25*figSize(2))];
ArgDescriptionTextAreaSize=[0.45 round(0.3*figSize(2))];
RunGroupButtonSize=[0.1 compHeight];
SubvariableUITreeSize=[0.2 round(0.15*figSize(2))];
ModifySubvariablesButtonSize=[0.2 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
AnalysisLabelPos=round([AnalysisLabelRelPos.*figSize AnalysisLabelSize(1)*figSize(1) AnalysisLabelSize(2)]);
SwitchAnalysisDropDownPos=round([SwitchAnalysisDropDownRelPos.*figSize SwitchAnalysisDropDownSize(1)*figSize(1) SwitchAnalysisDropDownSize(2)]);
NewAnalysisButtonPos=round([NewAnalysisButtonRelPos.*figSize NewAnalysisButtonSize(1)*figSize(1) NewAnalysisButtonSize(2)]);
ArchiveAnalysisButtonPos=round([ArchiveAnalysisButtonRelPos.*figSize ArchiveAnalysisButtonSize(1)*figSize(1) ArchiveAnalysisButtonSize(2)]);
FunctionsUITreeLabelPos=round([FunctionsUITreeLabelRelPos.*figSize FunctionsUITreeLabelSize(1)*figSize(1) FunctionsUITreeLabelSize(2)]);
ArgumentsUITreeLabelPos=round([ArgumentsUITreeLabelRelPos.*figSize ArgumentsUITreeLabelSize(1)*figSize(1) ArgumentsUITreeLabelSize(2)]);
FunctionsSearchBarEditFieldPos=round([FunctionsSearchBarEditFieldRelPos.*figSize FunctionsSearchBarEditFieldSize(1)*figSize(1) FunctionsSearchBarEditFieldSize(2)]);
ArgumentsSearchBarEditFieldPos=round([ArgumentsSearchBarEditFieldRelPos.*figSize ArgumentsSearchBarEditFieldSize(1)*figSize(1) ArgumentsSearchBarEditFieldSize(2)]);
FunctionsUITreePos=round([FunctionsUITreeRelPos.*figSize FunctionsUITreeSize(1)*figSize(1) FunctionsUITreeSize(2)]);
ArgumentsUITreePos=round([ArgumentsUITreeRelPos.*figSize ArgumentsUITreeSize(1)*figSize(1) ArgumentsUITreeSize(2)]);
NewGroupButtonPos=round([NewGroupButtonRelPos.*figSize NewGroupButtonSize(1)*figSize(1) NewGroupButtonSize(2)]);
ArchiveGroupButtonPos=round([ArchiveGroupButtonRelPos.*figSize ArchiveGroupButtonSize(1)*figSize(1) ArchiveGroupButtonSize(2)]);
NewFunctionButtonPos=round([NewFunctionButtonRelPos.*figSize NewFunctionButtonSize(1)*figSize(1) NewFunctionButtonSize(2)]);
ArchiveFunctionButtonPos=round([ArchiveFunctionButtonRelPos.*figSize ArchiveFunctionButtonSize(1)*figSize(1) ArchiveFunctionButtonSize(2)]);
FunctionToGroupButtonPos=round([FunctionToGroupButtonRelPos.*figSize FunctionToGroupButtonSize(1)*figSize(1) FunctionToGroupButtonSize(2)]);
FunctionFromGroupButtonPos=round([FunctionFromGroupButtonRelPos.*figSize FunctionFromGroupButtonSize(1)*figSize(1) FunctionFromGroupButtonSize(2)]);
ReorderGroupsButtonPos=round([ReorderGroupsButtonRelPos.*figSize ReorderGroupsButtonSize(1)*figSize(1) ReorderGroupsButtonSize(2)]);
ReorderFunctionsButtonPos=round([ReorderFunctionsButtonRelPos.*figSize ReorderFunctionsButtonSize(1)*figSize(1) ReorderFunctionsButtonSize(2)]);
NewArgumentButtonPos=round([NewArgumentButtonRelPos.*figSize NewArgumentButtonSize(1)*figSize(1) NewArgumentButtonSize(2)]);
ArchiveArgumentButtonPos=round([ArchiveArgumentButtonRelPos.*figSize ArchiveArgumentButtonSize(1)*figSize(1) ArchiveArgumentButtonSize(2)]);
AddInputArgumentButtonPos=round([AddInputArgumentButtonRelPos.*figSize AddInputArgumentButtonSize(1)*figSize(1) AddInputArgumentButtonSize(2)]);
AddOutputArgumentButtonPos=round([AddOutputArgumentButtonRelPos.*figSize AddOutputArgumentButtonSize(1)*figSize(1) AddOutputArgumentButtonSize(2)]);
RemoveArgumentButtonPos=round([RemoveArgumentButtonRelPos.*figSize RemoveArgumentButtonSize(1)*figSize(1) RemoveArgumentButtonSize(2)]);
ManualArgumentCheckboxPos=round([ManualArgumentCheckboxRelPos.*figSize ManualArgumentCheckboxSize(1)*figSize(1) ManualArgumentCheckboxSize(2)]);
EditNameLabelPos=round([EditNameLabelRelPos.*figSize EditNameLabelSize(1)*figSize(1) EditNameLabelSize(2)]);
EditNameEditFieldPos=round([EditNameEditFieldRelPos.*figSize EditNameEditFieldSize(1)*figSize(1) EditNameEditFieldSize(2)]);
ManualSaveArgButtonPos=round([ManualSaveArgButtonRelPos.*figSize ManualSaveArgButtonSize(1)*figSize(1) ManualSaveArgButtonSize(2)]);
ArgFcnNameLabelPos=round([ArgFcnNameLabelRelPos.*figSize ArgFcnNameLabelSize(1)*figSize(1) ArgFcnNameLabelSize(2)]);
% AnalysisDescriptionLabelPos=round([AnalysisDescriptionLabelRelPos.*figSize AnalysisDescriptionLabelSize(1)*figSize(1) AnalysisDescriptionLabelSize(2)]);
AnalysisDescriptionButtonPos=round([AnalysisDescriptionButtonRelPos.*figSize AnalysisDescriptionButtonSize(1)*figSize(1) AnalysisDescriptionButtonSize(2)]);
GenRunCodeButtonPos=round([GenRunCodeButtonRelPos.*figSize GenRunCodeButtonSize(1)*figSize(1) GenRunCodeButtonSize(2)]);
ArgNameLabelPos=round([ArgNameLabelRelPos.*figSize ArgNameLabelSize(1)*figSize(1) ArgNameLabelSize(2)]);
NameInCodeEditFieldPos=round([NameInCodeEditFieldRelPos.*figSize NameInCodeEditFieldSize(1)*figSize(1) NameInCodeEditFieldSize(2)]);
ArgLevelLabelPos=round([ArgLevelLabelRelPos.*figSize ArgLevelLabelSize(1)*figSize(1) ArgLevelLabelSize(2)]);
LevelDropDownPos=round([LevelDropDownRelPos.*figSize LevelDropDownSize(1)*figSize(1) LevelDropDownSize(2)]);
SubvariablesLabelPos=round([SubvariablesLabelRelPos.*figSize SubvariablesLabelSize(1)*figSize(1) SubvariablesLabelSize(2)]);
SubvariablesIndexEditFieldPos=round([SubvariablesIndexEditFieldRelPos.*figSize SubvariablesIndexEditFieldSize(1)*figSize(1) SubvariablesIndexEditFieldSize(2)]);
GroupSpecifyTrialsLabelPos=round([GroupSpecifyTrialsLabelRelPos.*figSize GroupSpecifyTrialsLabelSize(1)*figSize(1) GroupSpecifyTrialsLabelSize(2)]);
GroupSpecifyTrialsButtonPos=round([GroupSpecifyTrialsButtonRelPos.*figSize GroupSpecifyTrialsButtonSize(1)*figSize(1) GroupSpecifyTrialsButtonSize(2)]);
FunctionSpecifyTrialsLabelPos=round([FunctionSpecifyTrialsLabelRelPos.*figSize FunctionSpecifyTrialsLabelSize(1)*figSize(1) FunctionSpecifyTrialsLabelSize(2)]);
FunctionSpecifyTrialsButtonPos=round([FunctionSpecifyTrialsButtonRelPos.*figSize FunctionSpecifyTrialsButtonSize(1)*figSize(1) FunctionSpecifyTrialsButtonSize(2)]);
GroupFcnDescriptionLabelPos=round([GroupFcnDescriptionLabelRelPos.*figSize GroupFcnDescriptionLabelSize(1)*figSize(1) GroupFcnDescriptionLabelSize(2)]);
GroupFcnDescriptionTextAreaPos=round([GroupFcnDescriptionTextAreaRelPos.*figSize GroupFcnDescriptionTextAreaSize(1)*figSize(1) GroupFcnDescriptionTextAreaSize(2)]);
ArgDescriptionTextAreaPos=round([ArgDescriptionTextAreaRelPos.*figSize ArgDescriptionTextAreaSize(1)*figSize(1) ArgDescriptionTextAreaSize(2)]);
RunGroupButtonPos=round([RunGroupButtonRelPos.*figSize RunGroupButtonSize(1)*figSize(1) RunGroupButtonSize(2)]);
SubvariableUITreePos=round([SubvariableUITreeRelPos.*figSize SubvariableUITreeSize(1)*figSize(1) SubvariableUITreeSize(2)]);
ModifySubvariablesButtonPos=round([ModifySubvariablesButtonRelPos.*figSize ModifySubvariablesButtonSize(1)*figSize(1) ModifySubvariablesButtonSize(2)]);

%% Set position
data.AnalysisLabel.Position=AnalysisLabelPos;
data.SwitchAnalysisDropDown.Position=SwitchAnalysisDropDownPos;
data.NewAnalysisButton.Position=NewAnalysisButtonPos;
data.ArchiveAnalysisButton.Position=ArchiveAnalysisButtonPos;
data.FunctionsUITreeLabel.Position=FunctionsUITreeLabelPos;
data.ArgumentsUITreeLabel.Position=ArgumentsUITreeLabelPos;
data.FunctionsSearchBarEditField.Position=FunctionsSearchBarEditFieldPos;
data.ArgumentsSearchBarEditField.Position=ArgumentsSearchBarEditFieldPos;
data.FunctionsUITree.Position=FunctionsUITreePos;
data.ArgumentsUITree.Position=ArgumentsUITreePos;
data.NewGroupButton.Position=NewGroupButtonPos;
data.ArchiveGroupButton.Position=ArchiveGroupButtonPos;
data.NewFunctionButton.Position=NewFunctionButtonPos;
data.ArchiveFunctionButton.Position=ArchiveFunctionButtonPos;
data.FunctionToGroupButton.Position=FunctionToGroupButtonPos;
data.FunctionFromGroupButton.Position=FunctionFromGroupButtonPos;
data.ReorderGroupsButton.Position=ReorderGroupsButtonPos;
data.ReorderFunctionsButton.Position=ReorderFunctionsButtonPos;
data.NewArgumentButton.Position=NewArgumentButtonPos;
data.ArchiveArgumentButton.Position=ArchiveArgumentButtonPos;
data.AddInputArgumentButton.Position=AddInputArgumentButtonPos;
data.AddOutputArgumentButton.Position=AddOutputArgumentButtonPos;
data.RemoveArgumentButton.Position=RemoveArgumentButtonPos;
data.ManualArgumentCheckbox.Position=ManualArgumentCheckboxPos;
data.EditNameLabel.Position=EditNameLabelPos;
data.EditNameEditField.Position=EditNameEditFieldPos;
data.ManualSaveArgButton.Position=ManualSaveArgButtonPos;
data.ArgFcnNameLabel.Position=ArgFcnNameLabelPos;
% data.AnalysisDescriptionLabel.Position=AnalysisDescriptionLabelPos;
data.AnalysisDescriptionButton.Position=AnalysisDescriptionButtonPos;
data.GenRunCodeButton.Position=GenRunCodeButtonPos;
data.ArgNameLabel.Position=ArgNameLabelPos;
data.NameInCodeEditField.Position=NameInCodeEditFieldPos;
data.ArgLevelLabel.Position=ArgLevelLabelPos;
data.LevelDropDown.Position=LevelDropDownPos;
data.SubvariablesLabel.Position=SubvariablesLabelPos;
data.SubvariablesIndexEditField.Position=SubvariablesIndexEditFieldPos;
data.GroupSpecifyTrialsLabel.Position=GroupSpecifyTrialsLabelPos;
data.GroupSpecifyTrialsButton.Position=GroupSpecifyTrialsButtonPos;
data.FunctionSpecifyTrialsLabel.Position=FunctionSpecifyTrialsLabelPos;
data.FunctionSpecifyTrialsButton.Position=FunctionSpecifyTrialsButtonPos;
data.GroupFcnDescriptionLabel.Position=GroupFcnDescriptionLabelPos;
data.GroupFcnDescriptionTextArea.Position=GroupFcnDescriptionTextAreaPos;
data.ArgDescriptionTextArea.Position=ArgDescriptionTextAreaPos;
data.RunGroupButton.Position=RunGroupButtonPos;
data.SubvariableUITree.Position=SubvariableUITreePos;
data.ModifySubvariablesButton.Position=ModifySubvariablesButtonPos;

%% Set font size
data.AnalysisLabel.FontSize=newFontSize;
data.SwitchAnalysisDropDown.FontSize=newFontSize;
data.NewAnalysisButton.FontSize=newFontSize;
data.ArchiveAnalysisButton.FontSize=newFontSize;
data.FunctionsUITreeLabel.FontSize=newFontSize;
data.ArgumentsUITreeLabel.FontSize=newFontSize;
data.FunctionsSearchBarEditField.FontSize=newFontSize;
data.ArgumentsSearchBarEditField.FontSize=newFontSize;
data.FunctionsUITree.FontSize=newFontSize;
data.ArgumentsUITree.FontSize=newFontSize;
data.NewGroupButton.FontSize=newFontSize;
data.ArchiveGroupButton.FontSize=newFontSize;
data.NewFunctionButton.FontSize=newFontSize;
data.ArchiveFunctionButton.FontSize=newFontSize;
data.FunctionToGroupButton.FontSize=newFontSize;
data.FunctionFromGroupButton.FontSize=newFontSize;
data.ReorderGroupsButton.FontSize=newFontSize;
data.ReorderFunctionsButton.FontSize=newFontSize;
data.NewArgumentButton.FontSize=newFontSize;
data.ArchiveArgumentButton.FontSize=newFontSize;
data.AddInputArgumentButton.FontSize=newFontSize;
data.AddOutputArgumentButton.FontSize=newFontSize;
data.RemoveArgumentButton.FontSize=newFontSize;
data.ManualArgumentCheckbox.FontSize=newFontSize;
data.EditNameLabel.FontSize=newFontSize;
data.EditNameEditField.FontSize=newFontSize;
data.ManualSaveArgButton.FontSize=newFontSize;
data.ArgFcnNameLabel.FontSize=newFontSize;
% data.AnalysisDescriptionLabel.FontSize=newFontSize;
data.AnalysisDescriptionButton.FontSize=newFontSize;
data.GenRunCodeButton.FontSize=newFontSize;
data.ArgNameLabel.FontSize=newFontSize;
data.NameInCodeEditField.FontSize=newFontSize;
data.ArgLevelLabel.FontSize=newFontSize;
data.LevelDropDown.FontSize=newFontSize;
data.SubvariablesLabel.FontSize=newFontSize;
data.SubvariablesIndexEditField.FontSize=newFontSize;
data.GroupSpecifyTrialsLabel.FontSize=newFontSize;
data.GroupSpecifyTrialsButton.FontSize=newFontSize;
data.FunctionSpecifyTrialsLabel.FontSize=newFontSize;
data.FunctionSpecifyTrialsButton.FontSize=newFontSize;
data.GroupFcnDescriptionLabel.FontSize=newFontSize;
data.GroupFcnDescriptionTextArea.FontSize=newFontSize;
data.ArgDescriptionTextArea.FontSize=newFontSize;
data.RunGroupButton.FontSize=newFontSize;
data.SubvariableUITree.FontSize=newFontSize;
data.ModifySubvariablesButton.FontSize=newFontSize;