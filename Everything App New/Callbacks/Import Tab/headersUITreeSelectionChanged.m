function []=headersUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA IN THE DROPDOWNS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;
struct=loadJSON(uuid);

headers={struct.LogsheetVar_Params.Headers};

header=handles.Import.headersUITree.SelectedNodes.Text;

idx=ismember(headers,header);

level=struct.LogsheetVar_Params(idx).Level;
type=struct.LogsheetVar_Params(idx).Type;

handles.Import.levelDropDown.Value=level;
handles.Import.typeDropDown.Value=type;