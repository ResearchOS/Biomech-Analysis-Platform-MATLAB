function []=levelDropDownValueChanged(src,event)

%% PURPOSE: UPDATE THE LEVEL OF THE CURRENT VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.headersUITree.SelectedNodes;

if isempty(selNode)
    handles.Import.levelDropDown.Value='';
    return;
end

selNodeLogsheet=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNodeLogsheet)
    return;
end

uuid = selNodeLogsheet.NodeData.UUID;

struct=loadJSON(uuid);

headers={struct.LogsheetVar_Params.Headers};

header=selNode.Text;

idx=ismember(headers,header);

struct.LogsheetVar_Params(idx).Level=handles.Import.levelDropDown.Value;

writeJSON(struct);