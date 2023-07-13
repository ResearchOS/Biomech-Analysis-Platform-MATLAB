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
    case 'Plot'
        class='Plot';
        isPS=true;
end

%% Get the instance of the class that is currently selected.
switch class
    case 'Logsheet'
        uiTree=handles.Import.allLogsheetsUITree;
        text=uiTree.SelectedNodes.Text;

        if isempty(text)
            return;
        end
    case 'Process'
        uiTree=handles.Process.groupUITree;
        text=uiTree.SelectedNodes.Text;

        if isempty(text)
            return;
        end
    case 'Plot'
        text=handles.Plot.currentPlotLabel.Text;
end

fullPath=getClassFilePath(text, class);

classStruct=loadJSON(fullPath);

if isempty(src.CheckedNodes)
    classStruct.SpecifyTrials={};
else
    classStruct.SpecifyTrials={src.CheckedNodes.Text};
end

if isPS
    saveClass_PS(class, classStruct);
else
    saveClass(class, classStruct);
end

%% If checked, link the specify trials to the current process struct!
% If unchecked, unlink the specify trials from the current process struct.
linkObjs(stStruct, processStruct);