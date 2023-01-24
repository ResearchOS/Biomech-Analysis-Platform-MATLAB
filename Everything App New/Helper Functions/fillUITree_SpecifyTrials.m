function []=fillUITree_SpecifyTrials(src)

%% PURPOSE: FILL IN ALL OF THE SPECIFY TRIALS UI TREES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTrees=[handles.Import.allSpecifyTrialsUITree; handles.Process.allSpecifyTrialsUITree; ...
    handles.Plot.allSpecifyTrialsUITree];

for i=1:length(uiTrees)
    fillUITree(fig, 'SpecifyTrials', uiTrees(i), '')
end