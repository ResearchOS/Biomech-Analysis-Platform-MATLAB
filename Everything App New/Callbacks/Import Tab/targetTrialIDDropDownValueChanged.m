function []=targetTrialIDDropDownValueChanged(src,event)

%% PURPOSE: SPECIFY THE TARGET TRIAL NAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

struct=loadJSON(uuid);

handles.Import.targetTrialIDDropDown.Items = handles.Import.targetTrialIDDropDown.Items(~ismember(handles.Import.targetTrialIDDropDown.Items,{''}));

value=handles.Import.targetTrialIDDropDown.Value;

struct.TargetTrialIDHeader=value;

writeJSON(getJSONPath(struct), struct);