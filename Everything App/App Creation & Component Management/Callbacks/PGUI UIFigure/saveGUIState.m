function []=saveGUIState(fig)

%% PURPOSE: SAVE THE SETTINGS VARIABLES TO THE MAT FILE WHEN CLOSING THE GUI TO SAVE ALL PROGRESS.
% GETS RID OF THE NEED TO SAVE ALL SETTINGS AT EVERY STEP.

fig=ancestor(fig,'figure','toplevel');

VariableNamesList=getappdata(fig,'VariableNamesList');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
Plotting=getappdata(fig,'Plotting');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

save(projectSettingsMATPath,'VariableNamesList','Digraph','NonFcnSettingsStruct','Plotting','-append');