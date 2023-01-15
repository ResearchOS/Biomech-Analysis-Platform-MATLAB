function []=saveClass_PS(src,class,classStruct)

%% PURPOSE: SAVE THE PROJECT-SPECIFIC CLASS

slash=filesep;

fig=ancestor(src,'figure','toplevel');

filename=[class '_' classStruct.Text];

projectPath=getProjectPath(fig);

classFolder=[projectPath slash 'Project_Settings' slash class];

filepath=[classFolder slash filename];

classStruct.DateModified=datetime('now');

json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath, json);