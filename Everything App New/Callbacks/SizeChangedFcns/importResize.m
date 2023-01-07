function importResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE IMPORT TAB

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Modify component location
figSize=src.Position(3:4); % Width x height

%% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
if isempty(handles)
    return;
else
    tab=handles.Import;
    fldNames=fieldnames(tab);
    if isequal(fldNames{1},'Tab') && length(fldNames)==1
        return;
    end
end

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(tab.logsheetPathField,'FontSize'); % Get the initial font size
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

% 1. Logsheets label
objResize(tab.logsheetsLabel, [0.01 0.95], [0.15 compHeight]);

% 2. Add new logsheet button
objResize(tab.addLogsheetButton, [0.18 0.95], [0.05 compHeight]);

% 3. Remove logsheet button
objResize(tab.removeLogsheetButton, [0.24 0.95], [0.05 compHeight]);

% 4. Sort logsheets dropdown
objResize(tab.sortLogsheetsDropDown, [0.2 0.9], [0.1 compHeight]);

% 5. All logsheets UI Tree
objResize(tab.allLogsheetsUITree, [0.01 0.4], [0.3 0.5]);

% 6. Logsheet search field
objResize(tab.searchField, [0.01 0.9], [0.15 compHeight]);

% 7. Logsheet path field
objResize(tab.logsheetPathField, [0.6 0.9], [0.2 compHeight]);

% 8. Logsheet path button
objResize(tab.logsheetPathButton, [0.45 0.9], [0.15 compHeight]);

% 9. Open logsheet path button
objResize(tab.openLogsheetPathButton, [0.8 0.9], [0.05 compHeight]);

% 10. Number of header rows label
objResize(tab.numHeaderRowsLabel, [0.01 0.35], [0.2 compHeight]);

% 11. Number of header rows numeric edit field
objResize(tab.numHeaderRowsField, [0.22 0.35], [0.08 compHeight]);

% 12. Subject codename label
objResize(tab.subjectCodenameLabel, [0.01 0.3], [0.25 compHeight]);

% 13. Subject codename edit field
objResize(tab.subjectCodenameDropDown, [0.26 0.3], [0.2 compHeight]);

% 14. Target trial ID label
objResize(tab.targetTrialIDLabel, [0.01 0.25], [0.25 compHeight]);

% 15. Target trial ID edit field
objResize(tab.targetTrialIDDropDown, [0.26 0.25], [0.2 compHeight]);

% 18. Specify trials label
objResize(tab.specifyTrialsLabel, [0.01 0.06], [0.1 compHeight]);

% 19. Specify trials button
objResize(tab.specifyTrialsButton, [0.01 0.01], [0.1 compHeight]);

% 20. Header variables UI Tree
objResize(tab.headersUITree, [0.5 0.4], [0.4 0.4]);

% 21. Levels drop down
objResize(tab.levelDropDown, [0.5 0.35], [0.1 compHeight]);

% 22. Type drop down
objResize(tab.typeDropDown, [0.65 0.35], [0.1 compHeight]);

% 23. Check all button
objResize(tab.checkAllButton, [0.5 0.8], [0.1 compHeight]);

% 24. Uncheck all button
objResize(tab.uncheckAllButton, [0.65 0.8], [0.1 compHeight]);

% 25. Run logsheet button
objResize(tab.runLogsheetButton, [0.8 0.2], [0.1 compHeight]);