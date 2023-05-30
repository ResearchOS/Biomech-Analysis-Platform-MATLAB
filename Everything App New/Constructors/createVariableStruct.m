function [struct]=createVariableStruct(name,id)

%% PURPOSE: CREATE A NEW VARIABLE STRUCTURE
% Properties:
% GUI name (equivalent to how it is saved to the file): 
% default name in code: 
% split ID: 
% project names: 
% data: Contains the actual data for that variable
% date created:
% date modified:
% input to these functions (INCLUDE FULL STACK?): 
% output from these functions (INCLUDE FULL STACK?):
% description: 
% specifyTrials: 

struct.Name=name;

struct.Class='Variable';

if nargin==1 || isempty(id)
    id=createID('Variable');
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

% For argument validation
struct.VariableType=''; % What type is this variable
struct.VariableSize=[]; % What is the size of this variable
% struct.VariableDimLabels={}; % What is the description of each dimension of the variable

struct.InputToPlots={};
struct.InputToComponents={};
struct.InputToStatsTables={};
struct.InputToPubTables={};

struct.IsHardCoded=false; % By default, this variable is dynamic (from file), not hard-coded.

struct.Level='T'; % Must choose ONE: 'T' for trial is the default. 'S' for subject, and 'P' for project.

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass('Variable',struct);

%% Assign the newly created variable struct to the current project struct.
assignToProject(struct);