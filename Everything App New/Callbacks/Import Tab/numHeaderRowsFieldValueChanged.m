function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SPECIFY THE NUMBER OF HEADER ROWS FOR THE CURRENT LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    handles.Import.numHeaderRowsField.Value=-1;
    return;
end

uuid = selNode.NodeData.UUID;

struct=loadJSON(uuid);

value=handles.Import.numHeaderRowsField.Value;

struct.NumHeaderRows=value;

writeJSON(getJSONPath(struct), struct);