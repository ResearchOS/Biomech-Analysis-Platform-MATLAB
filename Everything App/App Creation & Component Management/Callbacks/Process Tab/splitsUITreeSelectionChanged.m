function []=splitsUITreeSelectionChanged(src,splitName_Code)

%% PURPOSE: SWITCH THE DISPLAY BETWEEN SPLITS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(fig,'Digraph');

if exist('splitName_Code','var')==1
    handles.Process.splitsUITree.SelectedNodes=findobj(handles.Process.splitsUITree,'Text',splitName_Code);
    runLog=false;
else
    if isempty(handles.Process.splitsUITree.SelectedNodes)
        handles.Process.splitsUITree.SelectedNodes=handles.Process.splitsUITree.Children(1);
    end
    splitName_Code=handles.Process.splitsUITree.SelectedNodes.Text;
    runLog=true;
end

setappdata(fig,'doHighlight',1);
highlightedFcnsChanged(fig,Digraph);
setappdata(fig,'doHighlight',0);

if runLog
    desc='Changed the selected split in the splitsUITree';
    updateLog(fig,desc,splitName_Code);
end