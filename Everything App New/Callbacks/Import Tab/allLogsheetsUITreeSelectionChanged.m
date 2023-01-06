function []=allLogsheetsUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA FOR THE CURRENTLY SELECTED LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

logsheet=selNode.Text;

classVar=getappdata(fig,'Logsheet');
idx=ismember({classVar.Text},logsheet);

computerID=getComputerID();

% Set the logsheet path field.
if exist(classVar(idx).LogsheetPath.(computerID),'file')==2
    handles.Import.logsheetPathField.Value=classVar(idx).LogsheetPath.(computerID);
else
    handles.Import.logsheetPathField.Value='Enter Logsheet Path';
end

% Set the number of header rows.
handles.Import.numHeaderRowsField.Value=classVar(idx).NumHeaderRows;

%% Set the items in the headers drop downs, reading from the logsheet
% headers=getLogsheetHeaders(fig,computerID);
headers={''};

% Set the subject codename header
handles.Import.subjectCodenameDropDown.Items=headers;
if ismember(classVar(idx).SubjectCodenameHeader,headers)
    value=classVar(idx).SubjectCodenameHeader;
else
    value='';
end
handles.Import.subjectCodenameDropDown.Value=value;

% Set the target trial column header
handles.Import.targetTrialIDColumnHeader.Items=headers;
if ismember(classVar(idx).TargetTrialIDHeader,headers)
    value=classVar(idx).TargetTrialIDHeader;
else
    value='';
end
handles.Import.targetTrialIDColumnHeader=value;