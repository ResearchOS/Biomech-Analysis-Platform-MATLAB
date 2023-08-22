function []=subjectCodenameDropDownValueChanged(src,event)

%% PURPOSE: SPECIFY THE SUBJECT CODENAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid=selNode.NodeData.UUID;

struct=loadJSON(uuid);

handles.Import.subjectCodenameDropDown.Items = handles.Import.subjectCodenameDropDown.Items(~ismember(handles.Import.subjectCodenameDropDown.Items,{''}));

value=handles.Import.subjectCodenameDropDown.Value;

struct.SubjectCodenameHeader=value;

writeJSON(getJSONPath(struct),struct);