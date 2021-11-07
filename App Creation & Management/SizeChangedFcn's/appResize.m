function []=appResize(src,event)

%% PURPOSE: RESIZE THE TAB GROUP (IMPORT, PROCESS, PLOT, STATS TABS)

data=src.UserData; % Get UserData to access components.

% Get figure size
figPos=src.Position(3:4); % Position of the figure on the screen. Syntax: left offset, bottom offset, width, height (pixels)

% Resize the tab group
data.tabGroup1.Position=[0 0 figPos(1) figPos(2)];