function []=dataTypeImportMethodFieldValueChanged(src)

%% PURPOSE: STORE THE PROJECT NAME TO THE APP DATA, AND TO THE TEXT FILE IN THE DOCUMENTS FOLDER.
% After the project is specified, there will always be a 'allProjects_ProjectNamesPaths.txt' file (unless deleted)

methodNum=src.Value;
fig=ancestor(src,'figure','toplevel');

hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
currType=hDataTypesDropDown.Value;
setappdata(fig,[currType 'ImportNum'],methodNum);

%% Save this to file
% Format:
% Prefix: 'Data Types:'
% 'FP1, MOCAP2'