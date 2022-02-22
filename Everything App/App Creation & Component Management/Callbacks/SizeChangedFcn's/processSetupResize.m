function [fontSizeRelToHeight]=processSetupResize(src)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE PROCESS > SETUP TAB

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
setupGroupNameLabelRelPos=[0.02 0.9];
setupGroupNameDropDownRelPos=[0.2 0.9];
setupFunctionNamesLabelRelPos=[0.25 0.85];
setupFunctionNamesFieldRelPos=[0.02 0.05];
newFunctionPanelRelPos=[0.65 0.15];
saveGroupButtonRelPos=[0.72 0.9];
inputsLabelRelPos=[0.70 0.45];
% outputsLabelRelPos=[0.78 0.45];
inputCheckboxPRelPos=[0.72 0.4];
inputCheckboxSRelPos=[0.72 0.35];
inputCheckboxTRelPos=[0.72 0.3];
% outputCheckboxPRelPos=[0.78 0.4];
% outputCheckboxSRelPos=[0.78 0.35];
% outputCheckboxTRelPos=[0.78 0.3];
newFunctionButtonRelPos=[0.67 0.22];
openGroupSpecifyTrialsButtonRelPos=[0.65 0.9];
runGroupNameLabelRelPos=[0.02 0.9];
runGroupNameDropDownRelPos=[0.2 0.9];
runFunctionNamesLabelRelPos=[0.2 0.85];
groupRunCheckboxLabelRelPos=[0.05 0.85];
groupArgsCheckboxLabelRelPos=[0.50 0.85];
runGroupButtonRelPos=[0.4 0.05];
runAllButtonRelPos=[0.7 0.05];
runFunctionsPanelRelPos=[0.02 0.1];
selectFunctionSpecifyTrialsDropDownRelPos=[0.65 0.85];
addFunctionGroupButtonRelPos=[0.6 0.9];
specifyTrialsGroupButtonRelPos=[0.65 0.9];
specifyTrialsCheckboxLabelRelPos=[0.7 0.85];
% specifyTrialsGroupCheckboxRelPos=[0.9 0.9];
processRunUpArrowButtonRelPos=[0.95 0.8];
processRunDownArrowButtonRelPos=[0.95 0.05];
    
%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text
setupGroupNameLabelSize=[0.2 compHeight];
setupGroupNameDropDownSize=[0.4 compHeight];
setupFunctionNamesLabelSize=[0.2 compHeight];
setupFunctionNamesFieldSize=[0.6 0.8*figSize(2)];
newFunctionPanelSize=[0.25 0.4*figSize(2)];
saveGroupButtonSize=[0.2 compHeight];
inputsLabelSize=[0.3 compHeight];
% outputsLabelSize=[0.2 compHeight];
inputCheckboxPSize=[0.15 compHeight];
inputCheckboxSSize=[0.15 compHeight];
inputCheckboxTSize=[0.15 compHeight];
% outputCheckboxPSize=[0.15 compHeight];
% outputCheckboxSSize=[0.15 compHeight];
% outputCheckboxTSize=[0.15 compHeight];
newFunctionButtonSize=[0.2 compHeight];
openGroupSpecifyTrialsButtonSize=[0.3 compHeight];
runGroupNameLabelSize=[0.2 compHeight];
runGroupNameDropDownSize=[0.4 compHeight];
runFunctionNamesLabelSize=[0.4 compHeight];
groupRunCheckboxLabelSize=[0.1 compHeight];
groupArgsCheckboxLabelSize=[0.1 compHeight];
runGroupButtonSize=[0.2 compHeight];
runAllButtonSize=[0.2 compHeight];
runFunctionsPanelSize=[0.95 0.75*figSize(2)];
selectFunctionSpecifyTrialsDropDownSize=[0.3 compHeight];
addFunctionGroupButtonSize=[0.05 compHeight];
specifyTrialsGroupButtonSize=[0.2 compHeight];
specifyTrialsCheckboxLabelSize=[0.2 compHeight];
% specifyTrialsGroupCheckboxSize=[0.05 compHeight];
processRunUpArrowButtonSize=[0.05 compHeight*2];
processRunDownArrowButtonSize=[0.05 compHeight*2];

% Multiply the relative positions by the figure size to get the actual position.
setupGroupNameLabelPos=round([setupGroupNameLabelRelPos.*figSize setupGroupNameLabelSize(1)*figSize(1) setupGroupNameLabelSize(2)]);
setupGroupNameDropDownPos=round([setupGroupNameDropDownRelPos.*figSize setupGroupNameDropDownSize(1)*figSize(1) setupGroupNameDropDownSize(2)]);
setupFunctionNamesLabelPos=round([setupFunctionNamesLabelRelPos.*figSize setupFunctionNamesLabelSize(1)*figSize(1) setupFunctionNamesLabelSize(2)]);
setupFunctionNamesFieldPos=round([setupFunctionNamesFieldRelPos.*figSize setupFunctionNamesFieldSize(1)*figSize(1) setupFunctionNamesFieldSize(2)]);
newFunctionPanelPos=round([newFunctionPanelRelPos.*figSize newFunctionPanelSize(1)*figSize(1) newFunctionPanelSize(2)]);
saveGroupButtonPos=round([saveGroupButtonRelPos.*figSize saveGroupButtonSize(1)*figSize(1) saveGroupButtonSize(2)]);
inputsLabelPos=round([inputsLabelRelPos.*figSize inputsLabelSize(1)*figSize(1) inputsLabelSize(2)]);
% outputsLabelPos=round([outputsLabelRelPos.*figSize outputsLabelSize(1)*figSize(1) outputsLabelSize(2)]);
inputCheckboxPPos=round([inputCheckboxPRelPos.*figSize inputCheckboxPSize(1)*figSize(1) inputCheckboxPSize(2)]);
inputCheckboxSPos=round([inputCheckboxSRelPos.*figSize inputCheckboxSSize(1)*figSize(1) inputCheckboxSSize(2)]);
inputCheckboxTPos=round([inputCheckboxTRelPos.*figSize inputCheckboxTSize(1)*figSize(1) inputCheckboxTSize(2)]);
% outputCheckboxPPos=round([outputCheckboxPRelPos.*figSize outputCheckboxPSize(1)*figSize(1) outputCheckboxPSize(2)]);
% outputCheckboxSPos=round([outputCheckboxSRelPos.*figSize outputCheckboxSSize(1)*figSize(1) outputCheckboxSSize(2)]);
% outputCheckboxTPos=round([outputCheckboxTRelPos.*figSize outputCheckboxTSize(1)*figSize(1) outputCheckboxTSize(2)]);
newFunctionButtonPos=round([newFunctionButtonRelPos.*figSize newFunctionButtonSize(1)*figSize(1) newFunctionButtonSize(2)]);
openGroupSpecifyTrialsButtonPos=round([openGroupSpecifyTrialsButtonRelPos.*figSize openGroupSpecifyTrialsButtonSize(1)*figSize(1) openGroupSpecifyTrialsButtonSize(2)]);
runGroupNameLabelPos=round([runGroupNameLabelRelPos.*figSize runGroupNameLabelSize(1)*figSize(1) runGroupNameLabelSize(2)]);
runGroupNameDropDownPos=round([runGroupNameDropDownRelPos.*figSize runGroupNameDropDownSize(1)*figSize(1) runGroupNameDropDownSize(2)]);
runFunctionNamesLabelPos=round([runFunctionNamesLabelRelPos.*figSize runFunctionNamesLabelSize(1)*figSize(1) runFunctionNamesLabelSize(2)]);
groupRunCheckboxLabelPos=round([groupRunCheckboxLabelRelPos.*figSize groupRunCheckboxLabelSize(1)*figSize(1) groupRunCheckboxLabelSize(2)]);
groupArgsCheckboxLabelPos=round([groupArgsCheckboxLabelRelPos.*figSize groupArgsCheckboxLabelSize(1)*figSize(1) groupArgsCheckboxLabelSize(2)]);
runGroupButtonPos=round([runGroupButtonRelPos.*figSize runGroupButtonSize(1)*figSize(1) runGroupButtonSize(2)]);
runAllButtonPos=round([runAllButtonRelPos.*figSize runAllButtonSize(1)*figSize(1) runAllButtonSize(2)]);
runFunctionsPanelPos=round([runFunctionsPanelRelPos.*figSize runFunctionsPanelSize(1)*figSize(1) runFunctionsPanelSize(2)]);
selectFunctionSpecifyTrialsDropDownPos=round([selectFunctionSpecifyTrialsDropDownRelPos.*figSize selectFunctionSpecifyTrialsDropDownSize(1)*figSize(1) selectFunctionSpecifyTrialsDropDownSize(2)]);
addFunctionGroupButtonPos=round([addFunctionGroupButtonRelPos.*figSize addFunctionGroupButtonSize(1)*figSize(1) addFunctionGroupButtonSize(2)]);
specifyTrialsGroupButtonPos=round([specifyTrialsGroupButtonRelPos.*figSize specifyTrialsGroupButtonSize(1)*figSize(1) specifyTrialsGroupButtonSize(2)]);
specifyTrialsCheckboxLabelPos=round([specifyTrialsCheckboxLabelRelPos.*figSize specifyTrialsCheckboxLabelSize(1)*figSize(1) specifyTrialsCheckboxLabelSize(2)]);
% specifyTrialsGroupCheckboxPos=round([specifyTrialsGroupCheckboxRelPos.*figSize specifyTrialsGroupCheckboxSize(1)*figSize(1) specifyTrialsGroupCheckboxSize(2)]);
processRunUpArrowButtonPos=round([processRunUpArrowButtonRelPos.*figSize processRunUpArrowButtonSize(1)*figSize(1) processRunUpArrowButtonSize(2)]);
processRunDownArrowButtonPos=round([processRunDownArrowButtonRelPos.*figSize processRunDownArrowButtonSize(1)*figSize(1) processRunDownArrowButtonSize(2)]);

% Set the actual positions for each component
data.SetupGroupNameLabel.Position=setupGroupNameLabelPos;
data.SetupGroupNameDropDown.Position=setupGroupNameDropDownPos;
data.SetupFunctionNamesLabel.Position=setupFunctionNamesLabelPos;
data.SetupFunctionNamesField.Position=setupFunctionNamesFieldPos;
data.NewFunctionPanel.Position=newFunctionPanelPos;
data.SaveGroupButton.Position=saveGroupButtonPos;
data.InputsLabel.Position=inputsLabelPos;
% data.OutputsLabel.Position=outputsLabelPos;
data.InputCheckboxProject.Position=inputCheckboxPPos;
data.InputCheckboxSubject.Position=inputCheckboxSPos;
data.InputCheckboxTrial.Position=inputCheckboxTPos;
% data.OutputCheckboxProject.Position=outputCheckboxPPos;
% data.OutputCheckboxSubject.Position=outputCheckboxSPos;
% data.OutputCheckboxTrial.Position=outputCheckboxTPos;
data.NewFunctionButton.Position=newFunctionButtonPos;
data.OpenGroupSpecifyTrialsButton.Position=openGroupSpecifyTrialsButtonPos;
data.RunGroupNameLabel.Position=runGroupNameLabelPos;
data.RunGroupNameDropDown.Position=runGroupNameDropDownPos;
data.RunFunctionNamesLabel.Position=runFunctionNamesLabelPos;
data.GroupRunCheckboxLabel.Position=groupRunCheckboxLabelPos;
data.GroupArgsCheckboxLabel.Position=groupArgsCheckboxLabelPos;
data.RunGroupButton.Position=runGroupButtonPos;
data.RunAllButton.Position=runAllButtonPos;
data.RunFunctionsPanel.Position=runFunctionsPanelPos;
data.SelectFunctionSpecifyTrialsDropDown.Position=selectFunctionSpecifyTrialsDropDownPos;
data.AddFunctionGroupButton.Position=addFunctionGroupButtonPos;
data.SpecifyTrialsGroupButton.Position=specifyTrialsGroupButtonPos;
data.SpecifyTrialsCheckboxLabel.Position=specifyTrialsCheckboxLabelPos;
% data.SpecifyTrialsGroupCheckbox.Position=specifyTrialsGroupCheckboxPos;
data.ProcessRunUpArrowButton.Position=processRunUpArrowButtonPos;
data.ProcessRunDownArrowButton.Position=processRunDownArrowButtonPos;

% Set the font sizes for all components that use text
data.SetupGroupNameLabel.FontSize=newFontSize;
data.SetupGroupNameDropDown.FontSize=newFontSize;
data.SetupFunctionNamesLabel.FontSize=newFontSize;
data.SetupFunctionNamesField.FontSize=newFontSize;
data.NewFunctionPanel.FontSize=newFontSize;
data.SaveGroupButton.FontSize=newFontSize;
data.InputsLabel.FontSize=newFontSize;
% data.OutputsLabel.FontSize=newFontSize;
data.InputCheckboxProject.FontSize=newFontSize;
data.InputCheckboxSubject.FontSize=newFontSize;
data.InputCheckboxTrial.FontSize=newFontSize;
% data.OutputCheckboxProject.FontSize=newFontSize;
% data.OutputCheckboxSubject.FontSize=newFontSize;
% data.OutputCheckboxTrial.FontSize=newFontSize;
data.NewFunctionButton.FontSize=newFontSize;
data.OpenSpecifyTrialsButton.FontSize=newFontSize;
data.RunGroupNameLabel.FontSize=newFontSize;
data.RunGroupNameDropDown.FontSize=newFontSize;
data.RunFunctionNamesLabel.FontSize=newFontSize;
data.GroupRunCheckboxLabel.FontSize=newFontSize;
data.GroupArgsCheckboxLabel.FontSize=newFontSize;
data.RunGroupButton.FontSize=newFontSize;
data.RunAllButton.FontSize=newFontSize;
data.RunFunctionsPanel.FontSize=newFontSize;
data.SelectFunctionSpecifyTrialsDropDown.FontSize=newFontSize;
data.AddFunctionGroupButton.FontSize=newFontSize;
data.SpecifyTrialsGroupButton.FontSize=newFontSize;
data.SpecifyTrialsCheckboxLabel.FontSize=newFontSize;
% data.SpecifyTrialsGroupCheckbox.FontSize=newFontSize;
data.ProcessRunUpArrowButton.FontSize=newFontSize;
data.ProcessRunDownArrowButton.FontSize=newFontSize;

% Restore component visibility