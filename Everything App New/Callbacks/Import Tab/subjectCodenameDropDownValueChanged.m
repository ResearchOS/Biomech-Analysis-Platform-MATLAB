function []=subjectCodenameDropDownValueChanged(src,event)

%% PURPOSE: SPECIFY THE SUBJECT CODENAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

file=selNode.Text;

commonPath=getCommonPath();
classFolder=[commonPath slash 'Logsheet'];
fullPath=[classFolder slash 'Logsheet_' file '.json'];
struct=loadJSON(fullPath);

handles.Import.subjectCodenameDropDown.Items = handles.Import.subjectCodenameDropDown.Items(~ismember(handles.Import.subjectCodenameDropDown.Items,{''}));

value=handles.Import.subjectCodenameDropDown.Value;

struct.SubjectCodenameHeader=value;

saveClass('Logsheet',struct);