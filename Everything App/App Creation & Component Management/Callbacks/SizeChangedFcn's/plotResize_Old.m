function [fontSizeRelToHeight]=plotResize(src,event)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE PLOT TAB

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
        initFontSize=get(data.LogsheetPathField,FontSize); % Get the initial font size
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
AddFunctionButtonRelPos=[0.01 0.95];
TemplatesDropDownRelPos=[0.01 0.9];
ArchiveFunctionButtonRelPos=[0.01 0.85];
RestoreFunctionButtonRelPos=[0.01 0.8];
AddPlotTemplateButtonRelPos=[0.01 0.7];
ArchivePlotTemplateButtonRelPos=[0.01 0.65];
RestorePlotTemplateButtonRelPos=[0.01 0.6];
SaveFormatLabelRelPos=[0.03 0.5];
FigCheckboxRelPos=[0.01 0.45];
SVGCheckboxRelPos=[0.01 0.4];
PNGCheckboxRelPos=[0.01 0.35];
MP4CheckboxRelPos=[0.01 0.3];
PercSpeedEditFieldRelPos=[0.01 0.25];
IntervalEditFieldRelPos=[0.01 0.2];
FunctionsLabelRelPos=[0.1 0.9];
FunctionsSearchEditFieldRelPos=[0.1 0.85];
FunctionsUITreeRelPos=[0.1 0.01];
ArgumentsLabelRelPos=[0.3 0.9];
ArgumentsSearchEditFieldRelPos=[0.3 0.85];
ArgumentsUITreeRelPos=[0.3 0.01];
RootSavePathButtonRelPos=[0.1 0.95];
RootSavePathEditFieldRelPos=[0.2 0.95];
SneakPeekButtonRelPos=[0.4 0.95];
AnalysisLabelRelPos=[0.55 0.9];
AnalysisDropDownRelPos=[0.55 0.85];
SubvariablesLabelRelPos=[0.55 0.8];
SubvariablesUITreeRelPos=[0.55 0.6];
ModifySubvariablesButtonRelPos=[0.65 0.75];
GroupFcnDescriptionLabelRelPos=[0.55 0.5];
GroupFcnDescriptionTextAreaRelPos=[0.55 0.25];
ArgNameLabelRelPos=[0.55 0.2];
ArgNameInCodeEditFieldRelPos=[0.65 0.2];
ArgDescriptionTextAreaRelPos=[0.55 0.06];
SaveSubfolderRelPos=[0.55 0.01];
SaveSubfolderEditFieldRelPos=[0.65 0.01];
PlotButtonRelPos=[0.85 0.01];
SpecifyTrialsButtonRelPos=[0.85 0.95];
ByConditionCheckboxRelPos=[0.8 0.9];
GenerateRunCodeButtonRelPos=[0.8 0.75];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
AddFunctionButtonSize=[0.06 compHeight];
TemplatesDropDownSize=[0.08 compHeight];
ArchiveFunctionButtonSize=[0.06 compHeight];
RestoreFunctionButtonSize=[0.06 compHeight];
AddPlotTemplateButtonSize=[0.06 compHeight];
ArchivePlotTemplateButtonSize=[0.06 compHeight];
RestorePlotTemplateButtonSize=[0.06 compHeight];
SaveFormatLabelSize=[0.06 compHeight];
FigCheckboxSize=[0.06 compHeight];
SVGCheckboxSize=[0.06 compHeight];
PNGCheckboxSize=[0.06 compHeight];
MP4CheckboxSize=[0.06 compHeight];
PercSpeedEditFieldSize=[0.06 compHeight];
IntervalEditFieldSize=[0.06 compHeight];
FunctionsLabelSize=[0.15 compHeight];
FunctionsSearchEditFieldSize=[0.15 compHeight];
FunctionsUITreeSize=[0.15 round(0.8*figSize(2))];
ArgumentsLabelSize=[0.15 compHeight];
ArgumentsSearchEditFieldSize=[0.15 compHeight];
ArgumentsUITreeSize=[0.15 round(0.8*figSize(2))];
RootSavePathButtonSize=[0.1 compHeight];
RootSavePathEditFieldSize=[0.15 compHeight];
SneakPeekButtonSize=[0.1 compHeight];
AnalysisLabelSize=[0.1 compHeight];
AnalysisDropDownSize=[0.15 compHeight];
SubvariablesLabelSize=[0.15 compHeight];
SubvariablesUITreeSize=[0.1 round(0.2*figSize(2))];
ModifySubvariablesButtonSize=[0.1 compHeight];
GroupFcnDescriptionLabelSize=[0.15 compHeight];
GroupFcnDescriptionTextAreaSize=[0.3 round(0.2*figSize(2))];
ArgNameLabelSize=[0.15 compHeight];
ArgNameInCodeEditFieldSize=[0.15 compHeight];
ArgDescriptionTextAreaSize=[0.3 round(0.15*figSize(2))];
SaveSubfolderSize=[0.1 compHeight];
SaveSubfolderEditFieldSize=[0.1 compHeight];
PlotButtonSize=[0.1 compHeight];
SpecifyTrialsButtonSize=[0.1 compHeight];
ByConditionCheckboxSize=[0.1 compHeight];
GenerateRunCodeButtonSize=[0.15 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
AddFunctionButtonPos=round([AddFunctionButtonRelPos.*figSize AddFunctionButtonSize(1)*figSize(1) AddFunctionButtonSize(2)]);
TemplatesDropDownPos=round([TemplatesDropDownRelPos.*figSize TemplatesDropDownSize(1)*figSize(1) TemplatesDropDownSize(2)]);
ArchiveFunctionButtonPos=round([ArchiveFunctionButtonRelPos.*figSize ArchiveFunctionButtonSize(1)*figSize(1) ArchiveFunctionButtonSize(2)]);
RestoreFunctionButtonPos=round([RestoreFunctionButtonRelPos.*figSize RestoreFunctionButtonSize(1)*figSize(1) RestoreFunctionButtonSize(2)]);
AddPlotTemplateButtonPos=round([AddPlotTemplateButtonRelPos.*figSize AddPlotTemplateButtonSize(1)*figSize(1) AddPlotTemplateButtonSize(2)]);
ArchivePlotTemplateButtonPos=round([ArchivePlotTemplateButtonRelPos.*figSize ArchivePlotTemplateButtonSize(1)*figSize(1) ArchivePlotTemplateButtonSize(2)]);
RestorePlotTemplateButtonPos=round([RestorePlotTemplateButtonRelPos.*figSize RestorePlotTemplateButtonSize(1)*figSize(1) RestorePlotTemplateButtonSize(2)]);
SaveFormatLabelPos=round([SaveFormatLabelRelPos.*figSize SaveFormatLabelSize(1)*figSize(1) SaveFormatLabelSize(2)]);
FigCheckboxPos=round([FigCheckboxRelPos.*figSize FigCheckboxSize(1)*figSize(1) FigCheckboxSize(2)]);
SVGCheckboxPos=round([SVGCheckboxRelPos.*figSize SVGCheckboxSize(1)*figSize(1) SVGCheckboxSize(2)]);
PNGCheckboxPos=round([PNGCheckboxRelPos.*figSize PNGCheckboxSize(1)*figSize(1) PNGCheckboxSize(2)]);
MP4CheckboxPos=round([MP4CheckboxRelPos.*figSize MP4CheckboxSize(1)*figSize(1) MP4CheckboxSize(2)]);
PercSpeedEditFieldPos=round([PercSpeedEditFieldRelPos.*figSize PercSpeedEditFieldSize(1)*figSize(1) PercSpeedEditFieldSize(2)]);
IntervalEditFieldPos=round([IntervalEditFieldRelPos.*figSize IntervalEditFieldSize(1)*figSize(1) IntervalEditFieldSize(2)]);
FunctionsLabelPos=round([FunctionsLabelRelPos.*figSize FunctionsLabelSize(1)*figSize(1) FunctionsLabelSize(2)]);
FunctionsSearchEditFieldPos=round([FunctionsSearchEditFieldRelPos.*figSize FunctionsSearchEditFieldSize(1)*figSize(1) FunctionsSearchEditFieldSize(2)]);
FunctionsUITreePos=round([FunctionsUITreeRelPos.*figSize FunctionsUITreeSize(1)*figSize(1) FunctionsUITreeSize(2)]);
ArgumentsLabelPos=round([ArgumentsLabelRelPos.*figSize ArgumentsLabelSize(1)*figSize(1) ArgumentsLabelSize(2)]);
ArgumentsSearchEditFieldPos=round([ArgumentsSearchEditFieldRelPos.*figSize ArgumentsSearchEditFieldSize(1)*figSize(1) ArgumentsSearchEditFieldSize(2)]);
ArgumentsUITreePos=round([ArgumentsUITreeRelPos.*figSize ArgumentsUITreeSize(1)*figSize(1) ArgumentsUITreeSize(2)]);
RootSavePathButtonPos=round([RootSavePathButtonRelPos.*figSize RootSavePathButtonSize(1)*figSize(1) RootSavePathButtonSize(2)]);
RootSavePathEditFieldPos=round([RootSavePathEditFieldRelPos.*figSize RootSavePathEditFieldSize(1)*figSize(1) RootSavePathEditFieldSize(2)]);
SneakPeekButtonPos=round([SneakPeekButtonRelPos.*figSize SneakPeekButtonSize(1)*figSize(1) SneakPeekButtonSize(2)]);
AnalysisLabelPos=round([AnalysisLabelRelPos.*figSize AnalysisLabelSize(1)*figSize(1) AnalysisLabelSize(2)]);
AnalysisDropDownPos=round([AnalysisDropDownRelPos.*figSize AnalysisDropDownSize(1)*figSize(1) AnalysisDropDownSize(2)]);
SubvariablesLabelPos=round([SubvariablesLabelRelPos.*figSize SubvariablesLabelSize(1)*figSize(1) SubvariablesLabelSize(2)]);
SubvariablesUITreePos=round([SubvariablesUITreeRelPos.*figSize SubvariablesUITreeSize(1)*figSize(1) SubvariablesUITreeSize(2)]);
ModifySubvariablesButtonPos=round([ModifySubvariablesButtonRelPos.*figSize ModifySubvariablesButtonSize(1)*figSize(1) ModifySubvariablesButtonSize(2)]);
GroupFcnDescriptionLabelPos=round([GroupFcnDescriptionLabelRelPos.*figSize GroupFcnDescriptionLabelSize(1)*figSize(1) GroupFcnDescriptionLabelSize(2)]);
GroupFcnDescriptionTextAreaPos=round([GroupFcnDescriptionTextAreaRelPos.*figSize GroupFcnDescriptionTextAreaSize(1)*figSize(1) GroupFcnDescriptionTextAreaSize(2)]);
ArgNameLabelPos=round([ArgNameLabelRelPos.*figSize ArgNameLabelSize(1)*figSize(1) ArgNameLabelSize(2)]);
ArgNameInCodeEditFieldPos=round([ArgNameInCodeEditFieldRelPos.*figSize ArgNameInCodeEditFieldSize(1)*figSize(1) ArgNameInCodeEditFieldSize(2)]);
ArgDescriptionTextAreaPos=round([ArgDescriptionTextAreaRelPos.*figSize ArgDescriptionTextAreaSize(1)*figSize(1) ArgDescriptionTextAreaSize(2)]);
SaveSubfolderPos=round([SaveSubfolderRelPos.*figSize SaveSubfolderSize(1)*figSize(1) SaveSubfolderSize(2)]);
SaveSubfolderEditFieldPos=round([SaveSubfolderEditFieldRelPos.*figSize SaveSubfolderEditFieldSize(1)*figSize(1) SaveSubfolderEditFieldSize(2)]);
PlotButtonPos=round([PlotButtonRelPos.*figSize PlotButtonSize(1)*figSize(1) PlotButtonSize(2)]);
SpecifyTrialsButtonPos=round([SpecifyTrialsButtonRelPos.*figSize SpecifyTrialsButtonSize(1)*figSize(1) SpecifyTrialsButtonSize(2)]);
ByConditionCheckboxPos=round([ByConditionCheckboxRelPos.*figSize ByConditionCheckboxSize(1)*figSize(1) ByConditionCheckboxSize(2)]);
GenerateRunCodeButtonPos=round([GenerateRunCodeButtonRelPos.*figSize GenerateRunCodeButtonSize(1)*figSize(1) GenerateRunCodeButtonSize(2)]);
data.AddFunctionButton.Position=AddFunctionButtonPos;
data.TemplatesDropDown.Position=TemplatesDropDownPos;
data.ArchiveFunctionButton.Position=ArchiveFunctionButtonPos;
data.RestoreFunctionButton.Position=RestoreFunctionButtonPos;
data.AddPlotTemplateButton.Position=AddPlotTemplateButtonPos;
data.ArchivePlotTemplateButton.Position=ArchivePlotTemplateButtonPos;
data.RestorePlotTemplateButton.Position=RestorePlotTemplateButtonPos;
data.SaveFormatLabel.Position=SaveFormatLabelPos;
data.FigCheckbox.Position=FigCheckboxPos;
data.SVGCheckbox.Position=SVGCheckboxPos;
data.PNGCheckbox.Position=PNGCheckboxPos;
data.MP4Checkbox.Position=MP4CheckboxPos;
data.PercSpeedEditField.Position=PercSpeedEditFieldPos;
data.IntervalEditField.Position=IntervalEditFieldPos;
data.FunctionsLabel.Position=FunctionsLabelPos;
data.FunctionsSearchEditField.Position=FunctionsSearchEditFieldPos;
data.FunctionsUITree.Position=FunctionsUITreePos;
data.ArgumentsLabel.Position=ArgumentsLabelPos;
data.ArgumentsSearchEditField.Position=ArgumentsSearchEditFieldPos;
data.ArgumentsUITree.Position=ArgumentsUITreePos;
data.RootSavePathButton.Position=RootSavePathButtonPos;
data.RootSavePathEditField.Position=RootSavePathEditFieldPos;
data.SneakPeekButton.Position=SneakPeekButtonPos;
data.AnalysisLabel.Position=AnalysisLabelPos;
data.AnalysisDropDown.Position=AnalysisDropDownPos;
data.SubvariablesLabel.Position=SubvariablesLabelPos;
data.SubvariablesUITree.Position=SubvariablesUITreePos;
data.ModifySubvariablesButton.Position=ModifySubvariablesButtonPos;
data.GroupFcnDescriptionLabel.Position=GroupFcnDescriptionLabelPos;
data.GroupFcnDescriptionTextArea.Position=GroupFcnDescriptionTextAreaPos;
data.ArgNameLabel.Position=ArgNameLabelPos;
data.ArgNameInCodeEditField.Position=ArgNameInCodeEditFieldPos;
data.ArgDescriptionTextArea.Position=ArgDescriptionTextAreaPos;
data.SaveSubfolder.Position=SaveSubfolderPos;
data.SaveSubfolderEditField.Position=SaveSubfolderEditFieldPos;
data.PlotButton.Position=PlotButtonPos;
data.SpecifyTrialsButton.Position=SpecifyTrialsButtonPos;
data.ByConditionCheckbox.Position=ByConditionCheckboxPos;
data.GenerateRunCodeButton.Position=GenerateRunCodeButtonPos;
data.AddFunctionButton.FontSize=newFontSize;
data.TemplatesDropDown.FontSize=newFontSize;
data.ArchiveFunctionButton.FontSize=newFontSize;
data.RestoreFunctionButton.FontSize=newFontSize;
data.AddPlotTemplateButton.FontSize=newFontSize;
data.ArchivePlotTemplateButton.FontSize=newFontSize;
data.RestorePlotTemplateButton.FontSize=newFontSize;
data.SaveFormatLabel.FontSize=newFontSize;
data.FigCheckbox.FontSize=newFontSize;
data.SVGCheckbox.FontSize=newFontSize;
data.PNGCheckbox.FontSize=newFontSize;
data.MP4Checkbox.FontSize=newFontSize;
data.PercSpeedEditField.FontSize=newFontSize;
data.IntervalEditField.FontSize=newFontSize;
data.FunctionsLabel.FontSize=newFontSize;
data.FunctionsSearchEditField.FontSize=newFontSize;
data.FunctionsUITree.FontSize=newFontSize;
data.ArgumentsLabel.FontSize=newFontSize;
data.ArgumentsSearchEditField.FontSize=newFontSize;
data.ArgumentsUITree.FontSize=newFontSize;
data.RootSavePathButton.FontSize=newFontSize;
data.RootSavePathEditField.FontSize=newFontSize;
data.SneakPeekButton.FontSize=newFontSize;
data.AnalysisLabel.FontSize=newFontSize;
data.AnalysisDropDown.FontSize=newFontSize;
data.SubvariablesLabel.FontSize=newFontSize;
data.SubvariablesUITree.FontSize=newFontSize;
data.ModifySubvariablesButton.FontSize=newFontSize;
data.GroupFcnDescriptionLabel.FontSize=newFontSize;
data.GroupFcnDescriptionTextArea.FontSize=newFontSize;
data.ArgNameLabel.FontSize=newFontSize;
data.ArgNameInCodeEditField.FontSize=newFontSize;
data.ArgDescriptionTextArea.FontSize=newFontSize;
data.SaveSubfolder.FontSize=newFontSize;
data.SaveSubfolderEditField.FontSize=newFontSize;
data.PlotButton.FontSize=newFontSize;
data.SpecifyTrialsButton.FontSize=newFontSize;
data.ByConditionCheckbox.FontSize=newFontSize;
data.GenerateRunCodeButton.FontSize=newFontSize;