function [fullPath]=getClassFilePath(selNode)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

fig=ancestor(selNode,'figure','toplevel');
handles=getappdata(fig,'handles');

parent=selNode.Parent;

switch parent
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
    case handles.Stats.allStatsUITree
        class='Stats';
end

file=selNode.Text;

slash=filesep;

commonPath=getCommonPath(fig);
classFolder=[commonPath slash class];
fullPath=[classFolder slash class '_' file '.json'];