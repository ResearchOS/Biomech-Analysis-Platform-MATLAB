function [struct]=createProcessStruct(name,id)

%% PURPOSE: CREATE A NEW PROCESS FUNCTION STRUCTURE

struct.Name=name;

struct.MFileName=struct.Name;

struct.Class='Process';

if nargin==1
    id=createID('Process');
end
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate; % Reflects when metadata changed AND when the .m file was saved. Save time of .m file doesn't update until interaction

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Description='';

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.SpecifyTrials='';

struct.InputVariablesNamesInCode={};
struct.OutputVariablesNamesInCode={};

struct.Versions={};

struct.Level='T'; % Can be any/all of the following: 'T' for trial (default), 'S' for subject, 'P' for project.

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

% If true, this function will be highlighted as needing to be re-run.
% Ways to be out of date:
% 1. Any of the input variables' DateModified is after any of the output variables' DateModified
% 2. The function's .m file (and any subfunctions?) DateModified is after any of the input or output variables' DateModified
struct.OutOfDate=true;

struct.Checked=true;

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass('Process',struct);

%% Assign the newly created process struct to the current project struct.
assignToProject(struct);