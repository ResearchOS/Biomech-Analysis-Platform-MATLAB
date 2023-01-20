function []=specifyTrialsUITreeCheckedNodesChanged(src,event)

%% PURPOSE: CHANGE WHICH SPECIFY TRIALS ARE BEING RUN FOR THE CURRENT CLASS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab=handles.Tabs.tabGroup1.SelectedTab.Title;

%% Get which class is currently being modified.
switch tab
    case 'Import'
        class='Logsheet';
        isPS=false;
    case 'Process'
        class='Process';
        isPS=true;
end

%% Get the instance of the class that is currently selected.
switch class
    case 'Logsheet'
        uiTree=handles.Import.allLogsheetsUITree;
    case 'Process'
        uiTree=handles.Process.groupUITree;
end

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

if isPS
    fullPath=getClassFilePath_PS(selNode.Text, class, fig);
else
    fullPath=getClassFilePath(selNode.Text, class, fig);
end

classStruct=loadJSON(fullPath);

if isempty(src.CheckedNodes)
    classStruct.SpecifyTrials={};
else
    classStruct.SpecifyTrials={src.CheckedNodes.Text};
end

if isPS
    saveClass_PS(fig, class, classStruct);
else
    saveClass(fig, class, classStruct);
end