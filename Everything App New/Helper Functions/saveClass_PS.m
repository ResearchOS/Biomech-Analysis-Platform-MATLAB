function []=saveClass_PS(class,classStruct)

%% PURPOSE: SAVE THE PROJECT-SPECIFIC CLASS

slash=filesep;

filename=[class '_' classStruct.Text];

projectPath=getProjectPath();

classFolder=[projectPath slash 'Project_Settings' slash class];

filepath=[classFolder slash filename];

classStruct.DateModified=datetime('now');

json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath, json);