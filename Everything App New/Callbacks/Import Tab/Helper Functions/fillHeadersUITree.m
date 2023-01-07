function []=fillHeadersUITree(src,headers)

%% PURPOSE: FILL THE LOGSHEET HEADERS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

delete(handles.Import.headersUITree.Children);
for i=1:length(headers)
    uitreenode(handles.Import.headersUITree,'Text',headers{i});
end

handles.Import.headersUITree.SelectedNodes=handles.Import.headersUITree.Children(1);
headersUITreeSelectionChanged(fig);