function []=logsheetPathFieldValueChanged(src,event)

%% PURPOSE: STORE THE LOGSHEET PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Import.logsheetPathField.Value;

if isempty(path)
    return;
end

logsheet=handles.Import.allLogsheetsUITree.SelectedNodes.Text;

classVar=getappdata(fig,'Logsheet');
idx=ismember({classVar.Text},logsheet);

if exist(path,'file')~=2
    disp('Specified path is not a file or does not exist!');
    return;
end

computerID=getComputerID();

classVar(idx).LogsheetPath.(computerID)=path;

setappdata(fig,'Logsheet',classVar);

saveClass(fig,'Logsheet',classVar(idx));