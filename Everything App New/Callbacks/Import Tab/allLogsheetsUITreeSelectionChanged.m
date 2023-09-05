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

[type, abstractID, instanceID] = deText(uuid);

if isempty(instanceID)
    return; % Need to clear all GUI elements when abstract logsheet is selected.
end

newComputerProjectPaths(uuid);

computerID = getComputerID();

% Set the logsheet path field.
if exist(struct.Logsheet_Path.(computerID),'file')==2
    handles.Import.logsheetPathField.Value=struct.Logsheet_Path.(computerID);
else
    handles.Import.logsheetPathField.Value='Enter Logsheet Path';
end

% Set the number of header rows.
handles.Import.numHeaderRowsField.Value=struct.Num_Header_Rows;

%% Set the items in the headers drop downs, reading from the logsheet
params=struct.LogsheetVar_Params;
if isempty(params)
    headers = {};
else
    headers = {params.Header};
end

% Set the subject codename header
if ~isempty(headers)
    handles.Import.subjectCodenameDropDown.Items=headers;
    handles.Import.targetTrialIDDropDown.Items=headers;
else
    handles.Import.subjectCodenameDropDown.Items={''};
    handles.Import.targetTrialIDDropDown.Items={''};
end
if ismember(struct.Subject_Codename_Header,headers)
    value=struct.Subject_Codename_Header;
else
    handles.Import.subjectCodenameDropDown.Items=[{''} handles.Import.subjectCodenameDropDown.Items];
    value='';    
end
handles.Import.subjectCodenameDropDown.Value=value;

% Set the target trial column header
if ismember(struct.Target_TrialID_Header,headers)
    value=struct.Target_TrialID_Header;
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