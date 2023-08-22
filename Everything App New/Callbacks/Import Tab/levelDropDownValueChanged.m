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

headers=struct.Headers;
levels=struct.Level;

header=selNode.Text;

idx=ismember(headers,header);

levels{idx}=handles.Import.levelDropDown.Value;

struct.Level=levels;

writeJSON(getJSONPath(struct), struct);