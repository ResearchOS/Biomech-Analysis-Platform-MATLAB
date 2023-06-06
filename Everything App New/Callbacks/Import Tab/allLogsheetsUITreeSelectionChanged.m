function []=allLogsheetsUITreeSelectionChanged(src,needSave)

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

if ~isfield(struct.LogsheetPath,computerID)
    struct.LogsheetPath.(computerID)='';
    writeJSON(fullPath,struct);
end

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
if ~isempty(headers)
    handles.Import.subjectCodenameDropDown.Items=headers;
    handles.Import.targetTrialIDDropDown.Items=headers;
else
    handles.Import.subjectCodenameDropDown.Items={''};
    handles.Import.targetTrialIDDropDown.Items={''};
end
if ismember(struct.SubjectCodenameHeader,headers)
    value=struct.SubjectCodenameHeader;
else
    handles.Import.subjectCodenameDropDown.Items=[{''} handles.Import.subjectCodenameDropDown.Items];
    value='';    
end
handles.Import.subjectCodenameDropDown.Value=value;

% Set the target trial column header
if ismember(struct.TargetTrialIDHeader,headers)
    value=struct.TargetTrialIDHeader;
else
    handles.Import.targetTrialIDDropDown.Items=[{''} handles.Import.targetTrialIDDropDown.Items];
    value='';
end
handles.Import.targetTrialIDDropDown.Value=value;

% Fill logsheet headers UI tree
fillHeadersUITree(fig,headers);

% Set the current logsheet name in the project settings file
% If needSave var exists, then don't save.
if nargin~=2
    projectSettingsPath=getProjectSettingsFile();
    projectSettingsStruct=loadJSON(projectSettingsPath);
    projectSettingsStruct.Current_Logsheet=selNode.Text;
    writeJSON(projectSettingsPath,projectSettingsStruct);
end