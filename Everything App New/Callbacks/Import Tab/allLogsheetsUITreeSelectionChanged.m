function []=allLogsheetsUITreeSelectionChanged(src,needSave)

%% PURPOSE: UPDATE THE METADATA FOR THE CURRENTLY SELECTED LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;
struct=loadJSON(uuid);

computerID=getComputerID();

if ~isfield(struct.LogsheetPath,computerID)
    tmp = createNewObject(false, 'Logsheet', 'Default', '', '', false);
    struct.LogsheetPath.(computerID) = tmp.LogsheetPath.(computerID);
    writeJSON(getJSONPath(struct), struct);
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

% Set the current logsheet for the project.
setCurrent(struct.UUID, 'Current_Logsheet');

% Link the logsheet to the project.
Current_Project = getCurrent('Current_Project_Name');
linkObjs(struct.UUID, Current_Project);

%% Check the boxes for the specify trials for this logsheet.
st = getST(struct.UUID);
checkSpecifyTrialsUITree(st, handles.Import.allSpecifyTrialsUITree);