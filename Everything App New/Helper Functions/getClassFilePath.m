function [fullPath]=getClassFilePath(selNode,class,src)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

if ~ischar(selNode)
    parent=selNode.Parent;

    fig=ancestor(selNode,'figure','toplevel');
    handles=getappdata(fig,'handles');

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
        case handles.Process.allGroupsUITree
            class='ProcessGroup';
        case handles.Stats.allStatsUITree
            class='Stats';        
    end

    file=selNode.Text;
elseif nargin==3
    fig=ancestor(src,'figure','toplevel');
    handles=getappdata(fig,'handles');
    file=selNode; % Node text specified directly
end

slash=filesep;

commonPath=getCommonPath(fig);
classFolder=[commonPath slash class];
fullPath=[classFolder slash class '_' file '.json'];