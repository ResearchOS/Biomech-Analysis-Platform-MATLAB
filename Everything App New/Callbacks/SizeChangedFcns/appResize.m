function []=appResize(src, event)

%% PURPOSE: RESIZE THE TAB GROUP (IMPORT, PROCESS, PLOT, STATS TABS)


%% Tab group
data=src.UserData; % Get UserData to access components.

if isempty(data)
    return; % Called on uifigure creation
end

% Get figure size
figPos=src.Position(3:4); % Position of the figure on the screen. Syntax: left offset, bottom offset, width, height (pixels)

% Resize the tab group
data.TabGroup1.Visible='off';
data.TabGroup1.Position=[0 0 figPos(1) figPos(2)];
data.TabGroup1.Visible='on';

%% Each individual tab.
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
        initFontSize=get(handles.Projects.dataPathField,'FontSize'); % Get the initial font size
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
tabSize = handles.Projects.Tab.Position(3:4);

projectsResize(handles.Projects, compHeight, newFontSize, tabSize);
importResize(handles.Import, compHeight, newFontSize, tabSize);
processResize(handles.Process, compHeight, newFontSize, tabSize);
% plotResize(handles.Plot, compHeight, newFontSize, figSize);
% statsResize(handles.Stats, compHeight, newFontSize, figSize);
settingsResize(handles.Settings, compHeight, newFontSize, tabSize);