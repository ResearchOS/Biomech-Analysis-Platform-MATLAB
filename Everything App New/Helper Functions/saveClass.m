function []=saveClass(src,class,classStruct)

%% PURPOSE: SAVE A CLASS INSTANCE TO JSON FILE.

slash=filesep;

fig=ancestor(src,'figure','toplevel');

filename=[class '_' classStruct.Text];

commonPath=getCommonPath(fig);

classFolder=[commonPath slash class];

filepath=[classFolder slash filename];

classStruct.DateModified=datetime('now');

json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath,json);