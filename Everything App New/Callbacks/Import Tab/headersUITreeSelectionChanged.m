function []=headersUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA IN THE DROPDOWNS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

handles.Import.levelDropDown.Value = '';
handles.Import.typeDropDown.Value = '';

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;
struct=loadJSON(uuid);

if isnumeric(struct.LogsheetVar_Params(1).Headers)
    struct.LogsheetVar_Params.Headers = {};
    struct.LogsheetVar_Params.Level = {};
    struct.LogsheetVar_Params.Type = {};
    struct.LogsheetVar_Params.Variables = {};
end

headers=struct.LogsheetVar_Params.Headers;
if isempty(headers)
    headers = {};
else
    headers = {struct.LogsheetVar_Params.Headers};
end

header=handles.Import.headersUITree.SelectedNodes.Text;

idx=ismember(headers,header);

if ~any(idx)
    return;
end

level=struct.LogsheetVar_Params(idx).Level;
type=struct.LogsheetVar_Params(idx).Type;

handles.Import.levelDropDown.Value=level;
handles.Import.typeDropDown.Value=type;