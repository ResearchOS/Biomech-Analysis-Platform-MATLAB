function []=specifyTrialsResize(src,event)

%% PURPOSE: RESIZE THE SPECIFY TRIALS GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Modify component location
figSize=src.Position(3:4); % Width x height

%% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
if isempty(handles)
    return;
else
    tab=handles;
%     fldNames=fieldnames(tab);
%     if isequal(fldNames{1},'Tab') && length(fldNames)==1
%         return;
%     end
end

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,[defaultPos(3) defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(tab.logsheetLogicValueEditField,'FontSize'); % Get the initial font size
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
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}

fontSize = newFontSize;

% 1. Logsheet tab
objResize(handles.Tabs.tabGroup1, [0 0], [1 1]);

%% Logsheet
% 1. All logsheet headers UI tree
objResize(tab.logsheetHeadersUITree, [0.01 0.01], [0.3 0.8]);

% 2. Assign logsheet header button
objResize(tab.assignLogsheetHeaderButton, [0.32 0.7], [0.05 compHeight]);

% 3. Unassign logsheet header button
objResize(tab.unassignLogsheetHeaderButton, [0.32 0.55], [0.05 compHeight]);

% 4. Logic dropdown
objResize(tab.logsheetLogicDropDown, [0.75 0.6], [0.2 compHeight]);

% 5. Value edit field
objResize(tab.logsheetLogicValueEditField, [0.75 0.5], [0.2 compHeight]);

% 6. Selected logsheet headers UI tree
objResize(tab.selectedLogsheetHeadersUITree, [0.4 0.01], [0.3 0.8]);

%% Variables
% 1. All variables UI tree
objResize(tab.variablesUITree, [0.01 0.01], [0.3 0.8]);

% 2. Assign variables button
objResize(tab.assignVariablesButton, [0.32 0.7], [0.05 compHeight]);

% 3. Unassign variables button
objResize(tab.unassignVariablesButton, [0.32 0.55], [0.05 compHeight]);

% 4. Logic dropdown
objResize(tab.variablesLogicDropDown, [0.75 0.6], [0.2 compHeight]);

% 5. Value edit field
objResize(tab.variablesLogicValueEditField, [0.75 0.5], [0.2 compHeight]);

% 6. Selected variables UI tree
objResize(tab.selectedVariablesUITree, [0.4 0.01], [0.3 0.8]);