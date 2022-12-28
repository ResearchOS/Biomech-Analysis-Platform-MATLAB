function projectsResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS IN THE PROJECTS TAB.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

figSize=fig.Position(3:4); % Width x height. Used by objResize function

%% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
if isempty(handles)
    return;
else
    tab=handles.Projects;
    fldNames=fieldnames(tab);
    if isequal(fldNames{1},'Tab') && length(fldNames)==1
        return;
    end
end

%% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(tab.dataPathField,'FontSize'); % Get the initial font size
        fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
        setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
    end 
else
    fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
end

%% Set new font size & component height
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end

compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}

% 1. The project name label
objResize(tab.projectsLabel, [0.01 0.9], [0.15 compHeight]);

% 2. Add new project button
objResize(tab.addProjectButton, [0.06 0.9], [0.05 compHeight]);

% 3. Remove project button
objResize(tab.removeProjectButton, [0.12 0.9], [0.05 compHeight]);

% 4. Sort projects dropdown
objResize(tab.sortProjectsDropDown, [0.18 0.9], [0.1 compHeight]);

% 5. All projects UI tree
objResize(tab.allProjectsUITree, [0.01 0.4], [0.3 0.5]);

% 6. Load project snapshot button (settings & code only, not data)
objResize(tab.loadSnapshotButton, [0.8 0.2], [0.1 compHeight]);

% 7. Save project snapshot button (settings & code only, not data)
objResize(tab.saveSnapshotButton, [0.8 0.15], [0.1 compHeight]);

% 8. Project data path button
objResize(tab.dataPathButton, [0.45 0.8], [0.15 compHeight]);

% 9. Project data path edit field
objResize(tab.dataPathField, [0.6 0.8], [0.2 compHeight]);

% 10. Open data path button
objResize(tab.openDataPathButton, [0.8 0.8], [0.05 compHeight]);

% 11. Project folder path button
objResize(tab.projectPathButton, [0.45 0.85], [0.15 compHeight]);

% 12. Project folder path edit field
objResize(tab.projectPathField, [0.6 0.85], [0.2 compHeight]);

% 13. Open project path button
objResize(tab.openProjectPathButton, [0.8 0.85], [0.05 compHeight]);

% 14. Create project archive button (settings, code, & data)
% objResize(tab.createProjectArchiveButton, [0.9 0.05], [0.1 compHeight]);

% 15. Load project archive button (settings, code, & data)
% objResize(tab.loadProjectArchiveButton, [0.2 0.05], [0.1 compHeight]);