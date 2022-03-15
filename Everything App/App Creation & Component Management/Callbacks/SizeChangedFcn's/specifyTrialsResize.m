function []=specifyTrialsResize(src, event)

%% PURPOSE: RESIZE THE GUI FOR SPECIFY TRIALS

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
        initFontSize=get(data.SpecifyTrialsLabel,'FontSize'); % Get the initial font size
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
specifyTrialsLabelRelPos=[0.02 0.95];
specifyTrialsDropDownRelPos=[0.25 0.95];
specifyTrialsDropDownAddRelPos=[0.6 0.95];
specifyTrialsDropDownRemoveRelPos=[0.7 0.95];
includeConditionLabelRelPos=[0.02 0.8];
includeConditionDropDownRelPos=[0.2 0.8];
includeAddConditionButtonRelPos=[0.55 0.8];
includeRemoveConditionButtonRelPos=[0.65 0.8];
excludeConditionLabelRelPos=[0.02 0.8];
excludeConditionDropDownRelPos=[0.2 0.8];
excludeAddConditionButtonRelPos=[0.55 0.8];
excludeRemoveConditionButtonRelPos=[0.65 0.8];
includeUpArrowButtonRelPos=[0.92 0.6];
includeDownArrowButtonRelPos=[0.92 0.1];
excludeUpArrowButtonRelPos=[0.92 0.6];
excludeDownArrowButtonRelPos=[0.92 0.1];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text
specifyTrialsLabelSize=[0.2 compHeight];
specifyTrialsDropDownSize=[0.3 compHeight];
specifyTrialsDropDownAddSize=[0.05 compHeight];
specifyTrialsDropDownRemoveSize=[0.05 compHeight];
includeConditionLabelSize=[0.2 compHeight];
includeConditionDropDownSize=[0.3 compHeight];
includeAddConditionButtonSize=[0.05 compHeight];
includeRemoveConditionButtonSize=[0.05 compHeight];
excludeConditionLabelSize=[0.2 compHeight];
excludeConditionDropDownSize=[0.3 compHeight];
excludeAddConditionButtonSize=[0.05 compHeight];
excludeRemoveConditionButtonSize=[0.05 compHeight];
includeUpArrowButtonSize=[0.05 1.67*compHeight];
includeDownArrowButtonSize=[0.05 1.67*compHeight];
excludeUpArrowButtonSize=[0.05 1.67*compHeight];
excludeDownArrowButtonSize=[0.05 1.67*compHeight];

%% Multiply the relative positions by the figure size to get the actual position.
specifyTrialsLabelPos=round([specifyTrialsLabelRelPos.*figSize specifyTrialsLabelSize(1)*figSize(1) specifyTrialsLabelSize(2)]);
specifyTrialsDropDownPos=round([specifyTrialsDropDownRelPos.*figSize specifyTrialsDropDownSize(1)*figSize(1) specifyTrialsDropDownSize(2)]);
specifyTrialsDropDownAddPos=round([specifyTrialsDropDownAddRelPos.*figSize specifyTrialsDropDownAddSize(1)*figSize(1) specifyTrialsDropDownAddSize(2)]);
specifyTrialsDropDownRemovePos=round([specifyTrialsDropDownRemoveRelPos.*figSize specifyTrialsDropDownRemoveSize(1)*figSize(1) specifyTrialsDropDownRemoveSize(2)]);
includeConditionLabelPos=round([includeConditionLabelRelPos.*figSize includeConditionLabelSize(1)*figSize(1) includeConditionLabelSize(2)]);
includeAddConditionButtonPos=round([includeAddConditionButtonRelPos.*figSize includeAddConditionButtonSize(1)*figSize(1) includeAddConditionButtonSize(2)]);
includeRemoveConditionButtonPos=round([includeRemoveConditionButtonRelPos.*figSize includeRemoveConditionButtonSize(1)*figSize(1) includeRemoveConditionButtonSize(2)]);
includeConditionDropDownPos=round([includeConditionDropDownRelPos.*figSize includeConditionDropDownSize(1)*figSize(1) includeConditionDropDownSize(2)]);
excludeConditionLabelPos=round([excludeConditionLabelRelPos.*figSize excludeConditionLabelSize(1)*figSize(1) excludeConditionLabelSize(2)]);
excludeAddConditionButtonPos=round([excludeAddConditionButtonRelPos.*figSize excludeAddConditionButtonSize(1)*figSize(1) excludeAddConditionButtonSize(2)]);
excludeRemoveConditionButtonPos=round([excludeRemoveConditionButtonRelPos.*figSize excludeRemoveConditionButtonSize(1)*figSize(1) excludeRemoveConditionButtonSize(2)]);
excludeConditionDropDownPos=round([excludeConditionDropDownRelPos.*figSize excludeConditionDropDownSize(1)*figSize(1) excludeConditionDropDownSize(2)]);
includeUpArrowButtonPos=round([includeUpArrowButtonRelPos.*figSize includeUpArrowButtonSize(1)*figSize(1) includeUpArrowButtonSize(2)]);
includeDownArrowButtonPos=round([includeDownArrowButtonRelPos.*figSize includeDownArrowButtonSize(1)*figSize(1) includeDownArrowButtonSize(2)]);
excludeUpArrowButtonPos=round([excludeUpArrowButtonRelPos.*figSize excludeUpArrowButtonSize(1)*figSize(1) excludeUpArrowButtonSize(2)]);
excludeDownArrowButtonPos=round([excludeDownArrowButtonRelPos.*figSize excludeDownArrowButtonSize(1)*figSize(1) excludeDownArrowButtonSize(2)]);

%% Set the actual positions for each component
data.SpecifyTrialsLabel.Position=specifyTrialsLabelPos;
data.SpecifyTrialsDropDown.Position=specifyTrialsDropDownPos;
data.SpecifyTrialsDropDownAdd.Position=specifyTrialsDropDownAddPos;
data.SpecifyTrialsDropDownRemove.Position=specifyTrialsDropDownRemovePos;
data.IncludeExcludeTabGroup.Position=[0 0 figSize(1) figSize(2)*0.9];
data.IncludeLogStructTabGroup.Position=[0 0 figSize(1) figSize(2)*0.75];
data.ExcludeLogStructTabGroup.Position=[0 0 figSize(1) figSize(2)*0.75];
data.IncludeConditionLabel.Position=includeConditionLabelPos;
data.IncludeAddConditionButton.Position=includeAddConditionButtonPos;
data.IncludeRemoveConditionButton.Position=includeRemoveConditionButtonPos;
data.IncludeConditionDropDown.Position=includeConditionDropDownPos;
data.ExcludeConditionLabel.Position=excludeConditionLabelPos;
data.ExcludeAddConditionButton.Position=excludeAddConditionButtonPos;
data.ExcludeRemoveConditionButton.Position=excludeRemoveConditionButtonPos;
data.ExcludeConditionDropDown.Position=excludeConditionDropDownPos;
data.IncludeUpArrowButton.Position=includeUpArrowButtonPos;
data.IncludeDownArrowButton.Position=includeDownArrowButtonPos;
data.ExcludeUpArrowButton.Position=excludeUpArrowButtonPos;
data.ExcludeDownArrowButton.Position=excludeDownArrowButtonPos;

%% Set the font sizes for all components that use text
data.SpecifyTrialsLabel.FontSize=newFontSize;
data.SpecifyTrialsDropDown.FontSize=newFontSize;
data.SpecifyTrialsDropDownAdd.FontSize=newFontSize;
data.SpecifyTrialsDropDownRemove.FontSize=newFontSize;
data.IncludeConditionLabel.FontSize=newFontSize;
data.IncludeAddConditionButton.FontSize=newFontSize;
data.IncludeRemoveConditionButton.FontSize=newFontSize;
data.IncludeConditionDropDown.FontSize=newFontSize;
data.ExcludeConditionLabel.FontSize=newFontSize;
data.ExcludeAddConditionButton.FontSize=newFontSize;
data.ExcludeRemoveConditionButton.FontSize=newFontSize;
data.ExcludeConditionDropDown.FontSize=newFontSize;
data.IncludeUpArrowButton.FontSize=newFontSize;
data.IncludeDownArrowButton.FontSize=newFontSize;
data.ExcludeUpArrowButton.FontSize=newFontSize;
data.ExcludeDownArrowButton.FontSize=newFontSize;