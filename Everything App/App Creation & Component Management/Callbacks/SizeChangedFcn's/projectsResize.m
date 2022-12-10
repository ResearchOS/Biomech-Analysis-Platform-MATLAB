function []=projectsResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS IN THE PROJECTS TAB.

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
        initFontSize=get(data.DataPathField,'FontSize'); % Get the initial font size
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

compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}

% 1. The project name label
objResize(data.ProjectNameLabel, [0.01 0.95], [0.15 compHeight]);

% 2. Add new project button
objResize(data.AddProjectButton, [0.01 0.9], [0.05 compHeight]);

% 3. Remove project button
objResize(data.RemoveProjectButton, [0.43 0.95], [0.06 compHeight]);

% 4. Sort projects dropdown
objResize(data.SortProjectsDropDown, [0.15 0.95], [0.1 compHeight]);

% 5. All projects UI tree
objResize(data.AllProjectsUITree, [0.01 0.5], [0.3 0.4]);

% 6. Load project snapshot button (settings & code only, not data)
objResize(data.LoadSnapshotButton, [0.8 0.2], [0.1 compHeight]);

% 7. Save project snapshot button (settings & code only, not data)
objResize(data.SaveSnapshotButton, [0.8 0.15], [0.1 compHeight]);

% 8. Project data path button
objResize(data.DataPathButton, [0.01 0.85], [0.15 compHeight]);

% 9. Project data path edit field
objResize(data.DataPathField, [0.17 0.85], [0.2 compHeight]);

% 10. Open data path button
objResize(data.OpenDataPathButton, [0.37 0.85], [0.05 compHeight]);

% 11. Project folder path button
objResize(data.ProjectPathButton, [0.01 0.9], [0.15 compHeight]);

% 12. Project folder path edit field
objResize(data.ProjectPathField, [0.17 0.9], [0.2 compHeight]);

% 13. Open project path button
objResize(data.OpenProjectPathButton, [0.37 0.9], [0.05 compHeight]);

% 14. Create project archive button (settings, code, & data)
objResize(data.CreateProjectArchiveButton, [0.9 0.05], [0.1 compHeight]);

% 15. Load project archive button (settings, code, & data)
objResize(data.LoadProjectArchiveButton, [0.2 0.05], [0.1 compHeight]);