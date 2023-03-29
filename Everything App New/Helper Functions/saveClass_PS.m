function []=saveClass_PS(class,classStruct,date)

%% PURPOSE: SAVE THE PROJECT-SPECIFIC CLASS

slash=filesep;

filename=[class '_' classStruct.Text];

% projectPath=getProjectPath(1);

root=getCommonPath();

filepath=[root slash class slash 'Implementations' slash filename];

% classFolder=[projectPath slash 'Project_Settings' slash class];
% 
% filepath=[classFolder slash filename];

if nargin<3
    date=datetime('now');
end
classStruct.DateModified=date;

% json=jsonencode(classStruct,'PrettyPrint',true);

writeJSON(filepath, classStruct);