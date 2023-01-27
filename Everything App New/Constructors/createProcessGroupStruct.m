function [struct]=createProcessGroupStruct(fig,name,id)

%% PURPOSE: CREATE A NEW PROCESSING GROUP

struct.Name=name;

struct.Class='ProcessGroup';

if nargin<3
    id=createID(fig,'ProcessGroup');
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

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.SpecifyTrials='';

struct.ExecutionListNames={}; % List of functions/groups to execute.
struct.ExecutionListTypes={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass(fig,'ProcessGroup',struct);

%% Assign the newly created variable struct to the current project struct.
assignToProject(fig,struct,'ProcessGroup');