function [versions]=getVersions(piStruct)

%% PURPOSE: RETURN THE LIST OF VERSIONS FOR THIS PI OBJECT

slash=filesep;

piText=piStruct.Text;
class=piStruct.Class;

projects=piStruct.ForwardLinks_Project;

versions={};

for i=1:length(projects)

    project=projects{i};
    projectPath=getProjectPath(0,project);

    classFolder=[projectPath slash 'Project_Settings' slash class];

    listing=dir(classFolder);
    folders=[listing.isdir];
    listing=listing(~folders);

    names={listing.name}';

    vers=names(contains(names,piText));

    versions=[versions; vers];

end

versions=fileNames2Texts(versions);