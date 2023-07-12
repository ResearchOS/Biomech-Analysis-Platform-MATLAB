function [uiTree]=getUITreeFromClass(src, class,allOrCurr, stClass)

%% PURPOSE: RETURN THE UI TREE FOR THE PROVIDED CLASS.
% allowable values for "allOrCurr": "all", "curr"

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ischar(class) && length(class)==2
    class = className2Abbrev(class, true);
end

if exist('allOrCurr','var')~=1
    allOrCurr = 'all';
end

if isequal(allOrCurr,'all')
    switch class
        case 'Project'
            uiTree = handles.Projects.allProjectsUITree;
        case 'Logsheet'
            uiTree = handles.Import.allLogsheetsUITree;
        case 'Variable'
            uiTree = handles.Process.allVariablesUITree;
        case 'Process'
            uiTree = handles.Process.allProcessUITree;
        case 'ProcessGroup'
            uiTree = handles.Process.allGroupsUITree;
        case 'Analysis'
            uiTree = handles.Process.allAnalysesUITree;
        case 'SpecifyTrials'
            switch stClass
                case 'Logsheet'
                    uiTree = handles.Import.allSpecifyTrialsUITree;
                case 'Process'
                    uiTree = handles.Process.allSpecifyTrialsUITree;
            end
    end
elseif isequal(allOrCurr,'curr')
    % Some ambiguity here, because processes & process groups can be in
    % either the analysis or process group UI trees.
end

handles.Process.allProcessUITree