function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO JSON FILE.

slash=filesep;

filename=[class '_' classStruct.Text];

commonPath=getCommonPath();

classFolder=[commonPath slash class];

filepath=[classFolder slash filename];

if nargin<3
    date=datetime('now');
end

classStruct.DateModified=date;

json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath,json);