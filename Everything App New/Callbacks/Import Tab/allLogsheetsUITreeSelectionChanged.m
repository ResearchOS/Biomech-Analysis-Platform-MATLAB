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
handles.Import.logsheetPathField.Value=classVar(idx).LogsheetPath.(computerID);

% Set the number of header rows.

% Set the subject codename header

% Set the target trial column header