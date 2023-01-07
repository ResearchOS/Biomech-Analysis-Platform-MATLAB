function []=allLogsheetsUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA FOR THE CURRENTLY SELECTED LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath(selNode);

struct=loadJSON(fullPath);

computerID=getComputerID();

% Set the logsheet path field.
if exist(struct.LogsheetPath.(computerID),'file')==2
    handles.Import.logsheetPathField.Value=struct.LogsheetPath.(computerID);
else
    handles.Import.logsheetPathField.Value='Enter Logsheet Path';
end

% Set the number of header rows.
handles.Import.numHeaderRowsField.Value=struct.NumHeaderRows;

%% Set the items in the headers drop downs, reading from the logsheet
% headers=getLogsheetHeaders(fig,computerID);
headers=struct.Headers;

% Set the subject codename header
handles.Import.subjectCodenameDropDown.Items=headers;
if ismember(struct.SubjectCodenameHeader,headers)
    value=struct.SubjectCodenameHeader;
else
    value='';
end
handles.Import.subjectCodenameDropDown.Value=value;

% Set the target trial column header
handles.Import.targetTrialIDDropDown.Items=headers;
if ismember(struct.TargetTrialIDHeader,headers)
    value=struct.TargetTrialIDHeader;
else
    value='';
end
handles.Import.targetTrialIDDropDown.Value=value;

% Fill logsheet headers UI tree
fillHeadersUITree(fig,headers);