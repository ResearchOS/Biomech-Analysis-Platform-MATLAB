function []=savePSClass(src,class,classStruct)

%% PURPOSE: SAVE THE PROJECT-SPECIFIC CLASS

slash=filesep;

fig=ancestor(src,'figure','toplevel');

filename=[class '_' classStruct.Text];

projectPath=getProjectPath(fig);

classFolder=[projectPath slash 'Project_Settings' slash class];

filepath=[classFolder slash filename];

json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath, json);