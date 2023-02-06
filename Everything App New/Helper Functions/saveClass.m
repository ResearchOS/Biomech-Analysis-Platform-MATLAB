function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A PI CLASS INSTANCE TO JSON FILE.

[~,~,psid]=deText(classStruct.Text);

% assert(isempty(psid),'Cannot save an object version to the common folder!');

slash=filesep;

filename=[class '_' classStruct.Text];

if isempty(psid)
    rootPath=getCommonPath();
else
    projectPath=getProjectPath;
    rootPath=[projectPath slash 'Project_Settings'];
end

classFolder=[rootPath slash class];

filepath=[classFolder slash filename];

if nargin<3
    date=datetime('now');
end

writeJSON(filepath,classStruct,date);