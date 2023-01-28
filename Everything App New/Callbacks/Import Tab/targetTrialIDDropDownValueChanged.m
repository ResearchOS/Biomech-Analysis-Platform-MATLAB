function []=targetTrialIDDropDownValueChanged(src,event)

%% PURPOSE: SPECIFY THE TARGET TRIAL NAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

fullPath=getClassFilePath(selNode);

struct=loadJSON(fullPath);

value=handles.Import.targetTrialIDDropDown.Value;

struct.TargetTrialIDHeader=value;

saveClass('Logsheet',struct);