function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
% global gui;

a=evalin('base','whos;');
classes={a.class};
if ismember('GUI',classes)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is currently not supported');
    return;
end

gui = GUI; % Create the GUI object. Includes figure handle and handles for all components.
assignin('base','gui',gui); % Put the GUI object into the base workspace.

settingsPath=getSettingsPath(); % The path to the PGUI settings variables

%% Fill the objects with their correct values
