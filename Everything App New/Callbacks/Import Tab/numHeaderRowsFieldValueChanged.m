function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SPECIFY THE NUMBER OF HEADER ROWS FOR THE CURRENT LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

fullPath=getClassFilePath(selNode);

struct=loadJSON(fullPath);

value=handles.Import.numHeaderRowsField.Value;

struct.NumHeaderRows=value;

saveClass(fig,'Logsheet',struct);