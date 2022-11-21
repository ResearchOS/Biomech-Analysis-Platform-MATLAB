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

objResize(data.ProjectNameLabel, [0.01 0.95], [0.15 compHeight]);

objResize(data.DataPathButton, [0.01 0.85], [0.15 compHeight]);

objResize(data.CodePathButton, [0.01 0.9], [0.15 compHeight]);

objResize(data.AddProjectButton, [0.01 0.9], [0.05 compHeight]);

objResize(data.DataPathField, [0.17 0.85], [0.2 compHeight]);

objResize(data.CodePathField, [0.17 0.9], [0.2 compHeight]);

objResize(data.SwitchProjectsDropDown, [0.17 0.95], [0.2 compHeight]);

objResize(data.RemoveProjectButton, [0.43 0.95], [0.06 compHeight]);

objResize(data.OpenDataPathButton, [0.37 0.85], [0.05 compHeight]);

objResize(data.OpenCodePathButton, [0.37 0.9], [0.05 compHeight]);

objResize(data.OpenPISettingsPathButton, [0.8 0.95], [0.15 compHeight]);

objResize(data.ShowVarDropDown, [0.01 0.75], [0.2 compHeight]);

objResize(data.ShowVarButton, [0.22 0.75], [0.1 compHeight]);

objResize(data.SaveVarButton, [0.33 0.75], [0.1 compHeight]);

objResize(data.ArchiveButton, [0.9 0.05], [0.1 compHeight]);

objResize(data.ArchiveDataCheckbox, [0.9 0.15], [0.1 compHeight]);

objResize(data.LoadArchiveButton, [0.2 0.05], [0.1 compHeight]);