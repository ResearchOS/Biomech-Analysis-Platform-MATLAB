function []=createComponentStruct(fig,name,id)

%% PURPOSE: CREATE A NEW COMPONENT STRUCT

struct.Name=name;

struct.Type='Component';

if nargin<3
    id=createID(fig,'Component');
end
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Description='';

handles=getappdata(fig,'handles');
currentProject=handles.Projects.projectsLabel.Text;

struct.Project={currentProject};

struct.DefaultInputVariables={};
struct.InputVariables={};

struct.ModifiedDefaultProperties={}; % List of property names to have the defaults modified for
struct.ModifiedPropertyValues={}; % The new default values of those properties

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

struct.Checked=true;

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass(fig,'Component',struct);

classVar=getappdata(fig,'Component');

if isempty(classVar)
    classVar=struct;
else
    classVar(end+1)=struct;
end

setappdata(fig,'Component',classVar);

%% Assign the newly created plot component struct to the current project struct.
assignToProject(fig,struct,'Component');