function []=appResize(src, event)

%% PURPOSE: RESIZE THE TAB GROUP (IMPORT, PROCESS, PLOT, STATS TABS)

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

%% RESIZE THE MAP FIGURE COMPONENTS
