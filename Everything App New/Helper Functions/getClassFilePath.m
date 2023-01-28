function [fullPath]=getClassFilePath(selNode,class)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

if isempty(selNode)
    fullPath='';
    return;
end

% This allows this one function to do both project-independent and
% project-specific actions (should be cleaned up in the future.
if ischar(selNode)
    [name, id, psid]=deText(selNode);
    if ~isempty(psid)
        [fullPath]=getClassFilePath_PS(selNode, class);
        return;
    end
end

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
    end

    file=selNode.Text;
else
    file=selNode; % Node text specified directly
end

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];
fullPath=[classFolder slash class '_' file '.json'];