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
AddFunctionButtonRelPos=[0.5 0.5];
TemplatesDropDownRelPos=[0.5 0.5];
ArchiveFunctionButtonRelPos=[0.5 0.5];
RestoreFunctionButtonRelPos=[0.5 0.5];
AddPlotTemplateButtonRelPos=[0.5 0.5];
ArchivePlotTemplateButtonRelPos=[0.5 0.5];
RestorePlotTemplateButtonRelPos=[0.5 0.5];
SaveFormatLabelRelPos=[0.5 0.5];
FigCheckboxRelPos=[0.5 0.5];
SVGCheckboxRelPos=[0.5 0.5];
PNGCheckboxRelPos=[0.5 0.5];
MP4CheckboxRelPos=[0.5 0.5];
PercSpeedEditFieldRelPos=[0.5 0.5];
IntervalEditFieldRelPos=[0.5 0.5];
FunctionsLabelRelPos=[0.5 0.5];
FunctionsSearchEditFieldRelPos=[0.5 0.5];
FunctionsUITreeRelPos=[0.5 0.5];
ArgumentsLabelRelPos=[0.5 0.5];
ArgumentsSearchEditFieldRelPos=[0.5 0.5];
ArgumentsUITreeRelPos=[0.5 0.5];
RootSavePathButtonRelPos=[0.5 0.5];
RootSavePathEditFieldRelPos=[0.5 0.5];
SneakPeekButtonRelPos=[0.5 0.5];
AnalysisLabelRelPos=[0.5 0.5];
AnalysisDropDownRelPos=[0.5 0.5];
SubvariablesLabelRelPos=[0.5 0.5];
SubvariablesUITreeRelPos=[0.5 0.5];
ModifySubvariablesButtonRelPos=[0.5 0.5];
GroupFcnDescriptionLabelRelPos=[0.5 0.5];
GroupFcnDescriptionTextAreaRelPos=[0.5 0.5];
ArgNameLabelRelPos=[0.5 0.5];
ArgNameInCodeEditFieldRelPos=[0.5 0.5];
ArgDescriptionTextAreaRelPos=[0.5 0.5];
SaveSubfolderRelPos=[0.5 0.5];
SaveSubfolderEditFieldRelPos=[0.5 0.5];
PlotButtonRelPos=[0.5 0.5];
SpecifyTrialsButtonRelPos=[0.5 0.5];
ByConditionCheckboxRelPos=[0.5 0.5];
GenerateRunCodeButtonRelPos=[0.5 0.5];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
AddFunctionButtonSize=[0.2 compHeight];
TemplatesDropDownSize=[0.2 compHeight];
ArchiveFunctionButtonSize=[0.2 compHeight];
RestoreFunctionButtonSize=[0.2 compHeight];
AddPlotTemplateButtonSize=[0.2 compHeight];
ArchivePlotTemplateButtonSize=[0.2 compHeight];
RestorePlotTemplateButtonSize=[0.2 compHeight];
SaveFormatLabelSize=[0.2 compHeight];
FigCheckboxSize=[0.2 compHeight];
SVGCheckboxSize=[0.2 compHeight];
PNGCheckboxSize=[0.2 compHeight];
MP4CheckboxSize=[0.2 compHeight];
PercSpeedEditFieldSize=[0.2 compHeight];
IntervalEditFieldSize=[0.2 compHeight];
FunctionsLabelSize=[0.2 compHeight];
FunctionsSearchEditFieldSize=[0.2 compHeight];
FunctionsUITreeSize=[0.2 compHeight];
ArgumentsLabelSize=[0.2 compHeight];
ArgumentsSearchEditFieldSize=[0.2 compHeight];
ArgumentsUITreeSize=[0.2 compHeight];
RootSavePathButtonSize=[0.2 compHeight];
RootSavePathEditFieldSize=[0.2 compHeight];
SneakPeekButtonSize=[0.2 compHeight];
AnalysisLabelSize=[0.2 compHeight];
AnalysisDropDownSize=[0.2 compHeight];
SubvariablesLabelSize=[0.2 compHeight];
SubvariablesUITreeSize=[0.2 compHeight];
ModifySubvariablesButtonSize=[0.2 compHeight];
GroupFcnDescriptionLabelSize=[0.2 compHeight];
GroupFcnDescriptionTextAreaSize=[0.2 compHeight];
ArgNameLabelSize=[0.2 compHeight];
ArgNameInCodeEditFieldSize=[0.2 compHeight];
ArgDescriptionTextAreaSize=[0.2 compHeight];
SaveSubfolderSize=[0.2 compHeight];
SaveSubfolderEditFieldSize=[0.2 compHeight];
PlotButtonSize=[0.2 compHeight];
SpecifyTrialsButtonSize=[0.2 compHeight];
ByConditionCheckboxSize=[0.2 compHeight];
GenerateRunCodeButtonSize=[0.2 compHeight];

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