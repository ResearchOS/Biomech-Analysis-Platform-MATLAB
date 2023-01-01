function []=assignToProject(fig,struct,class)

%% PURPOSE: ASSIGN A NEWLY CREATED CLASS STRUCT TO THE CURRENT PROJECT.

slash=filesep;

handles=getappdata(fig,'handles');
currentProject=handles.Projects.projectsLabel.Text;

commonPath=getCommonPath(fig);
projectClassFolder=[commonPath slash 'Project'];
projectStructPath=[projectClassFolder slash 'Project_' currentProject '.json'];

projectStruct=loadJSON(projectStructPath);

if ~ismember(struct.Text,projectStruct.(class))
    projectStruct.(class)=[projectStruct.(class); {struct.Text}];
end

saveClass(fig,'Project',projectStruct);

classVar=loadClassVar(fig,projectClassFolder);
setappdata(fig,'Project',classVar);