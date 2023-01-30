function [class]=getClassFromUITree(uiTree)

%% PURPOSE: RELATE THE PROVIDED UI TREE TO ITS CORRESPONDING CLASS

fig=ancestor(uiTree,'figure','toplevel');
handles=getappdata(fig,'handles');

switch uiTree
    case handles.Projects.allProjectsUITree
        class='Project';
    case handles.Import.allLogsheetsUITree
        class='Logsheet';
    case handles.Process.allProcessUITree
        class='Process';
    case handles.Plot.allPlotsUITree
        class='Plot';
    case handles.Plot.allComponentsUITree
        class='Component';
    case handles.Process.allGroupsUITree
        class='ProcessGroup';
    case handles.Process.allVariablesUITree
        class='Variable';
    case handles.Import.allSpecifyTrialsUITree
        class='SpecifyTrials';
    case handles.Process.allSpecifyTrialsUITree
        class='SpecifyTrials';
    case handles.Process.groupUITree
        class='Process';
    case handles.Stats.allStatsUITree
        class='Stats';
    otherwise
        class='';
end