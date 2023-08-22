function []=typeDropDownValueChanged(src,event)

%% PURPOSE: UPDATE THE VARIABLE TYPE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.headersUITree.SelectedNodes;

if isempty(selNode)
    handles.Import.typeDropDown.Value='';
    return;
end

selNodeLogsheet=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNodeLogsheet)
    return;
end

uuid = selNodeLogsheet.NodeData.UUID;

struct=loadJSON(uuid);

headers=struct.Headers;
types=struct.Type;

header=selNode.Text;

idx=ismember(headers,header);

types{idx}=handles.Import.typeDropDown.Value;

struct.Type=types;

writeJSON(getJSONPath(struct), struct);