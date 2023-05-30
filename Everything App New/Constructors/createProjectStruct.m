function [struct]=createProjectStruct(name,id)

%% PURPOSE: CREATE A NEW PROJECT STRUCT

struct.Class='Project';

struct.Name=name;

if nargin==1 || isempty(id)
    id=createID('Project');
end
struct.ID=id; % Immutable

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

computerID=getComputerID();

struct.Description='';

struct.Variable={};

struct.Logsheet={};

struct.Plot={};

struct.StatsTable={};

struct.PubTable={};

struct.Process={};

struct.Component={};

struct.ProcessGroup={};

struct.SpecifyTrials={};

struct.DataPath.(computerID)='';

struct.ProjectPath.(computerID)='';

struct.Visible=true; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this will show up as having dependencies that need to be updated

struct.Checked=true; % If true, the uitreenode checkbox will be checked. If false, it will be unchecked.

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass('Project',struct);