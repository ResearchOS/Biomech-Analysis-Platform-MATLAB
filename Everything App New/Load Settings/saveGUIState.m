function []=saveGUIState(fig)

%% PURPOSE: SAVE THE SETTINGS VARIABLES TO THE MAT FILE WHEN CLOSING THE GUI TO SAVE ALL PROGRESS.
% GETS RID OF THE NEED TO SAVE ALL SETTINGS AT EVERY STEP.

global conn;
close(conn);

evalin('base','clear gui;');

clearAllMemoizedCaches; % Clears memoized caches. Using these caches greatly improves startup time.