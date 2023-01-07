function []=headersUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA IN THE DROPDOWNS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath(selNode);
struct=loadJSON(fullPath);

headers=struct.Headers;

header=handles.Import.headersUITree.SelectedNodes.Text;

idx=ismember(headers,header);

level=struct.Level{idx};
type=struct.Type{idx};

handles.Import.levelDropDown.Value=level;
handles.Import.typeDropDown.Value=type;