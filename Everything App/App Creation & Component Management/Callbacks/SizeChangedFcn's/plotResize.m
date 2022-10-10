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
defaultPos=get(0,'defaultFigurePosition');
if isequal(ancSize,defaultPos(3:4)) % If currently in default figure size
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
AllComponentsSearchFieldRelPos=[0.01 0.9];
AllComponentsUITreeRelPos=[0.01 0.5];
PlotFcnSearchFieldRelPos=[0.01 0.41];
PlotFcnUITreeRelPos=[0.01 0.01];
AssignVarsButtonRelPos=[0.22 0.8];
AssignComponentButtonRelPos=[0.22 0.75];
UnassignComponentButtonRelPos=[0.22 0.7];
CreateFcnButtonRelPos=[0.15 0.455];
AxLimsButtonRelPos=[0.5 0.95];
FigSizeButtonRelPos=[0.6 0.95];
SaveExFigButtonRelPos=[0.7 0.95];
ExTrialButtonRelPos=[0.8 0.95];
ExTrialFigureRelPos=[0.5 0.07];
CurrComponentsUITreeRelPos=[0.3 0.55];
ComponentDescLabelRelPos=[0.35 0.5];
ComponentDescTextAreaRelPos=[0.3 0.3];
FcnVerDescLabelRelPos=[0.35 0.25];
FcnVerDescTextAreaRelPos=[0.3 0.05];
SpecifyTrialsButtonRelPos=[0.5 0.01];
RunPlotButtonRelPos=[0.8 0.01];
PlotLevelDropDownRelPos=[0.7 0.01];
AllComponentsLabelRelPos=[0.01 0.95];
AllFunctionsLabelRelPos=[0.01 0.45];
CurrComponentsLabelRelPos=[0.3 0.95];
CreateCompButtonRelPos=[0.15 0.95];
DeleteCompButtonRelPos=[0.08 0.95];
DeletePlotButtonRelPos=[0.08 0.455];
EditCompButtonRelPos=[0.41 0.95];
PlotPanelRelPos=[0.5 0.07];
IsMovieCheckboxRelPos=[0.22 0.4];
IncEditFieldRelPos=[0.95 0.95];
IncFrameUpButtonRelPos=[0.9 0.95];
IncFrameDownButtonRelPos=[0.85 0.95];
StartFrameButtonRelPos=[0.5 0.95];
StartFrameEditFieldRelPos=[0.575 0.95];
CurrFrameEditFieldRelPos=[0.615 0.95];
EndFrameEditFieldRelPos=[0.655 0.95];
EndFrameButtonRelPos=[0.7 0.95];
ExTrialLabelRelPos=[0.25 0.01];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
AllComponentsSearchFieldSize=[0.2 compHeight];
AllComponentsUITreeSize=[0.2 0.4];
PlotFcnSearchFieldSize=[0.2 compHeight];
PlotFcnUITreeSize=[0.2 0.4];
AssignVarsButtonSize=[0.07 compHeight];
AssignComponentButtonSize=[0.04 compHeight];
UnassignComponentButtonSize=[0.04 compHeight];
CreateFcnButtonSize=[0.05 compHeight];
AxLimsButtonSize=[0.1 compHeight];
FigSizeButtonSize=[0.1 compHeight];
SaveExFigButtonSize=[0.1 compHeight];
ExTrialButtonSize=[0.1 compHeight];
ExTrialFigureSize=[0.5 0.87];
CurrComponentsUITreeSize=[0.2 0.4];
ComponentDescLabelSize=[0.2 compHeight];
ComponentDescTextAreaSize=[0.2 0.2];
FcnVerDescLabelSize=[0.2 compHeight];
FcnVerDescTextAreaSize=[0.2 0.2];
SpecifyTrialsButtonSize=[0.1 compHeight];
RunPlotButtonSize=[0.1 compHeight];
PlotLevelDropDownSize=[0.06 compHeight];
AllComponentsLabelSize=[0.2 compHeight];
AllFunctionsLabelSize=[0.1 compHeight];
CurrComponentsLabelSize=[0.2 compHeight];
CreateCompButtonSize=[0.05 compHeight];
DeleteCompButtonSize=[0.05 compHeight];
DeletePlotButtonSize=[0.05 compHeight];
EditCompButtonSize=[0.06 compHeight];
PlotPanelSize=[0.5 0.87];
IsMovieCheckboxSize=[0.1 compHeight];
IncEditFieldSize=[0.03 compHeight];
IncFrameUpButtonSize=[0.04 compHeight];
IncFrameDownButtonSize=[0.04 compHeight];
StartFrameButtonSize=[0.07 compHeight];
StartFrameEditFieldSize=[0.04 compHeight];
CurrFrameEditFieldSize=[0.04 compHeight];
EndFrameEditFieldSize=[0.04 compHeight];
EndFrameButtonSize=[0.07 compHeight];
ExTrialLabelSize=[0.15 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
AllComponentsSearchFieldPos=round([AllComponentsSearchFieldRelPos.*figSize AllComponentsSearchFieldSize(1)*figSize(1) AllComponentsSearchFieldSize(2)]);
AllComponentsUITreePos=round([AllComponentsUITreeRelPos.*figSize AllComponentsUITreeSize.*figSize]);
PlotFcnSearchFieldPos=round([PlotFcnSearchFieldRelPos.*figSize PlotFcnSearchFieldSize(1)*figSize(1) PlotFcnSearchFieldSize(2)]);
PlotFcnUITreePos=round([PlotFcnUITreeRelPos.*figSize PlotFcnUITreeSize.*figSize]);
AssignVarsButtonPos=round([AssignVarsButtonRelPos.*figSize AssignVarsButtonSize(1)*figSize(1) AssignVarsButtonSize(2)]);
AssignComponentButtonPos=round([AssignComponentButtonRelPos.*figSize AssignComponentButtonSize(1)*figSize(1) AssignComponentButtonSize(2)]);
UnassignComponentButtonPos=round([UnassignComponentButtonRelPos.*figSize UnassignComponentButtonSize(1)*figSize(1) UnassignComponentButtonSize(2)]);
CreateFcnButtonPos=round([CreateFcnButtonRelPos.*figSize CreateFcnButtonSize(1)*figSize(1) CreateFcnButtonSize(2)]);
AxLimsButtonPos=round([AxLimsButtonRelPos.*figSize AxLimsButtonSize(1)*figSize(1) AxLimsButtonSize(2)]);
FigSizeButtonPos=round([FigSizeButtonRelPos.*figSize FigSizeButtonSize(1)*figSize(1) FigSizeButtonSize(2)]);
SaveExFigButtonPos=round([SaveExFigButtonRelPos.*figSize SaveExFigButtonSize(1)*figSize(1) SaveExFigButtonSize(2)]);
ExTrialButtonPos=round([ExTrialButtonRelPos.*figSize ExTrialButtonSize(1)*figSize(1) ExTrialButtonSize(2)]);
ExTrialFigurePos=round([ExTrialFigureRelPos.*figSize ExTrialFigureSize.*figSize]);
CurrComponentsUITreePos=round([CurrComponentsUITreeRelPos.*figSize CurrComponentsUITreeSize.*figSize]);
ComponentDescLabelPos=round([ComponentDescLabelRelPos.*figSize ComponentDescLabelSize(1)*figSize(1) ComponentDescLabelSize(2)]);
ComponentDescTextAreaPos=round([ComponentDescTextAreaRelPos.*figSize ComponentDescTextAreaSize.*figSize]);
FcnVerDescLabelPos=round([FcnVerDescLabelRelPos.*figSize FcnVerDescLabelSize(1)*figSize(1) FcnVerDescLabelSize(2)]);
FcnVerDescTextAreaPos=round([FcnVerDescTextAreaRelPos.*figSize FcnVerDescTextAreaSize.*figSize]);
SpecifyTrialsButtonPos=round([SpecifyTrialsButtonRelPos.*figSize SpecifyTrialsButtonSize(1)*figSize(1) SpecifyTrialsButtonSize(2)]);
RunPlotButtonPos=round([RunPlotButtonRelPos.*figSize RunPlotButtonSize(1)*figSize(1) RunPlotButtonSize(2)]);
PlotLevelDropDownPos=round([PlotLevelDropDownRelPos.*figSize PlotLevelDropDownSize(1)*figSize(1) PlotLevelDropDownSize(2)]);
AllComponentsLabelPos=round([AllComponentsLabelRelPos.*figSize AllComponentsLabelSize(1)*figSize(1) AllComponentsLabelSize(2)]);
AllFunctionsLabelPos=round([AllFunctionsLabelRelPos.*figSize AllFunctionsLabelSize(1)*figSize(1) AllFunctionsLabelSize(2)]);
CurrComponentsLabelPos=round([CurrComponentsLabelRelPos.*figSize CurrComponentsLabelSize(1)*figSize(1) CurrComponentsLabelSize(2)]);
CreateCompButtonPos=round([CreateCompButtonRelPos.*figSize CreateCompButtonSize(1)*figSize(1) CreateCompButtonSize(2)]);
DeleteCompButtonPos=round([DeleteCompButtonRelPos.*figSize DeleteCompButtonSize(1)*figSize(1) DeleteCompButtonSize(2)]);
DeletePlotButtonPos=round([DeletePlotButtonRelPos.*figSize DeletePlotButtonSize(1)*figSize(1) DeletePlotButtonSize(2)]);
EditCompButtonPos=round([EditCompButtonRelPos.*figSize EditCompButtonSize(1)*figSize(1) EditCompButtonSize(2)]);
PlotPanelPos=round([PlotPanelRelPos.*figSize PlotPanelSize.*figSize]);
IsMovieCheckboxPos=round([IsMovieCheckboxRelPos.*figSize IsMovieCheckboxSize(1)*figSize(1) IsMovieCheckboxSize(2)]);
IncEditFieldPos=round([IncEditFieldRelPos.*figSize IncEditFieldSize(1)*figSize(1) IncEditFieldSize(2)]);
IncFrameUpButtonPos=round([IncFrameUpButtonRelPos.*figSize IncFrameUpButtonSize(1)*figSize(1) IncFrameUpButtonSize(2)]);
IncFrameDownButtonPos=round([IncFrameDownButtonRelPos.*figSize IncFrameDownButtonSize(1)*figSize(1) IncFrameDownButtonSize(2)]);
StartFrameButtonPos=round([StartFrameButtonRelPos.*figSize StartFrameButtonSize(1)*figSize(1) StartFrameButtonSize(2)]);
StartFrameEditFieldPos=round([StartFrameEditFieldRelPos.*figSize StartFrameEditFieldSize(1)*figSize(1) StartFrameEditFieldSize(2)]);
CurrFrameEditFieldPos=round([CurrFrameEditFieldRelPos.*figSize CurrFrameEditFieldSize(1)*figSize(1) CurrFrameEditFieldSize(2)]);
EndFrameEditFieldPos=round([EndFrameEditFieldRelPos.*figSize EndFrameEditFieldSize(1)*figSize(1) EndFrameEditFieldSize(2)]);
EndFrameButtonPos=round([EndFrameButtonRelPos.*figSize EndFrameButtonSize(1)*figSize(1) EndFrameButtonSize(2)]);
ExTrialLabelPos=round([ExTrialLabelRelPos.*figSize ExTrialLabelSize(1)*figSize(1) ExTrialLabelSize(2)]);

data.AllComponentsSearchField.Position=AllComponentsSearchFieldPos;
data.AllComponentsUITree.Position=AllComponentsUITreePos;
data.PlotFcnSearchField.Position=PlotFcnSearchFieldPos;
data.PlotFcnUITree.Position=PlotFcnUITreePos;
data.AssignVarsButton.Position=AssignVarsButtonPos;
data.AssignComponentButton.Position=AssignComponentButtonPos;
data.UnassignComponentButton.Position=UnassignComponentButtonPos;
data.CreateFcnButton.Position=CreateFcnButtonPos;
data.AxLimsButton.Position=AxLimsButtonPos;
data.FigSizeButton.Position=FigSizeButtonPos;
data.SaveExFigButton.Position=SaveExFigButtonPos;
data.ExTrialButton.Position=ExTrialButtonPos;
% data.ExTrialFigure.Position=ExTrialFigurePos;
data.CurrComponentsUITree.Position=CurrComponentsUITreePos;
data.ComponentDescLabel.Position=ComponentDescLabelPos;
data.ComponentDescTextArea.Position=ComponentDescTextAreaPos;
data.FcnVerDescLabel.Position=FcnVerDescLabelPos;
data.FcnVerDescTextArea.Position=FcnVerDescTextAreaPos;
data.SpecifyTrialsButton.Position=SpecifyTrialsButtonPos;
data.RunPlotButton.Position=RunPlotButtonPos;
data.PlotLevelDropDown.Position=PlotLevelDropDownPos;
data.AllComponentsLabel.Position=AllComponentsLabelPos;
data.AllFunctionsLabel.Position=AllFunctionsLabelPos;
data.CurrComponentsLabel.Position=CurrComponentsLabelPos;
data.CreateCompButton.Position=CreateCompButtonPos;
data.DeleteCompButton.Position=DeleteCompButtonPos;
data.DeletePlotButton.Position=DeletePlotButtonPos;
data.EditCompButton.Position=EditCompButtonPos;
data.PlotPanel.Position=PlotPanelPos;
data.IsMovieCheckbox.Position=IsMovieCheckboxPos;
data.IncEditField.Position=IncEditFieldPos;
data.IncFrameUpButton.Position=IncFrameUpButtonPos;
data.IncFrameDownButton.Position=IncFrameDownButtonPos;
data.StartFrameButton.Position=StartFrameButtonPos;
data.StartFrameEditField.Position=StartFrameEditFieldPos;
data.CurrFrameEditField.Position=CurrFrameEditFieldPos;
data.EndFrameEditField.Position=EndFrameEditFieldPos;
data.EndFrameButton.Position=EndFrameButtonPos;
data.ExTrialLabel.Position=ExTrialLabelPos;

data.AllComponentsSearchField.FontSize=newFontSize;
data.AllComponentsUITree.FontSize=newFontSize;
data.PlotFcnSearchField.FontSize=newFontSize;
data.PlotFcnUITree.FontSize=newFontSize;
data.AssignVarsButton.FontSize=newFontSize;
data.AssignComponentButton.FontSize=newFontSize;
data.UnassignComponentButton.FontSize=newFontSize;
data.CreateFcnButton.FontSize=newFontSize;
data.AxLimsButton.FontSize=newFontSize;
data.FigSizeButton.FontSize=newFontSize;
data.SaveExFigButton.FontSize=newFontSize;
data.ExTrialButton.FontSize=newFontSize;
% data.ExTrialFigure.FontSize=newFontSize;
data.CurrComponentsUITree.FontSize=newFontSize;
data.ComponentDescLabel.FontSize=newFontSize;
data.ComponentDescTextArea.FontSize=newFontSize;
data.FcnVerDescLabel.FontSize=newFontSize;
data.FcnVerDescTextArea.FontSize=newFontSize;
data.SpecifyTrialsButton.FontSize=newFontSize;
data.RunPlotButton.FontSize=newFontSize;
data.PlotLevelDropDown.FontSize=newFontSize;
data.AllComponentsLabel.FontSize=newFontSize;
data.AllFunctionsLabel.FontSize=newFontSize;
data.CurrComponentsLabel.FontSize=newFontSize;
data.CreateCompButton.FontSize=newFontSize;
data.DeleteCompButton.FontSize=newFontSize;
data.DeletePlotButton.FontSize=newFontSize;
data.EditCompButton.FontSize=newFontSize;
data.PlotPanel.FontSize=newFontSize;
data.IsMovieCheckbox.FontSize=newFontSize;
data.IncEditField.FontSize=newFontSize;
data.IncFrameUpButton.FontSize=newFontSize;
data.IncFrameDownButton.FontSize=newFontSize;
data.StartFrameButton.FontSize=newFontSize;
data.StartFrameEditField.FontSize=newFontSize;
data.CurrFrameEditField.FontSize=newFontSize;
data.EndFrameEditField.FontSize=newFontSize;
data.EndFrameButton.FontSize=newFontSize;
data.ExTrialLabel.FontSize=newFontSize;