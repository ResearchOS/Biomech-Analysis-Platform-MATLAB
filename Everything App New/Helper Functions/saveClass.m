function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO JSON FILE.

[~,abstractID,instanceID]=deText(classStruct.UUID);

slash=filesep;

filename=classStruct.UUID;

rootPath=getCommonPath();

if ~isempty(instanceID)
    rootPath=[rootPath slash class slash 'Instances'];
else
    rootPath=[rootPath slash class];
end

filepath=[rootPath slash filename];

if nargin<3
    date=datetime('now');
end

writeJSON(filepath,classStruct,date);