function [struct]=createPlotStruct(fig,name,id)

%% PURPOSE: CREATE A NEW PLOT STRUCTURE
% Properties:
% plot name in GUI: 
% date created:
% date modified:
% dates saved (for opening most recent saved plot from GUI)
% description:
% axes:
%   components:
%       input variable GUI names
%       properties
% projects:
% specifyTrials:

struct.Name=name;

struct.Class='Plot';

if nargin<3
    id=createID(fig,'Plot');
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

struct.Level='';
struct.IsMovie=0;
struct.MovieMetadata.StartFrame=[];
struct.MovieMetadata.EndFrame=[];
struct.MovieMetadata.StartFrameVariable=''; % Empty indicates hard-coded
struct.MovieMetadata.EndFrameVariable=''; % Empty indicates hard-coded
struct.MovieMetadata.CurrFrame=[];
struct.MovieMetadata.Increment=1;

struct.SpecifyTrials='';
struct.ExampleCondition='';
struct.ExampleSubject='';
struct.ExampleTrial='';

struct.Component.Text={}; % Includes name & ID
struct.Component.Parent={}; % Includes name & ID
struct.Component.Children={}; % Includes name & ID
struct.Component.ModifiedProperties={}; % The names of the properties that have been modified

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

struct.Checked=true;

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass(fig,'Plot',struct);

%% Assign the newly created plot struct to the current project struct.
assignToProject(fig,struct,'Plot');