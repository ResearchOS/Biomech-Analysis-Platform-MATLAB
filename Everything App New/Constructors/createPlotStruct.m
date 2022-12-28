function [struct]=createPlotStruct(fig,name)

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

id=createID(fig,'Plot');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.Level='';
struct.IsMovie=0;
struct.MovieMetadata.StartFrame=1;
struct.MovieMetadata.EndFrame=2;
struct.MovieMetadata.StartFrameVariable=''; % Empty indicates hard-coded
struct.MovieMetadata.EndFrameVariable=''; % Empty indicates hard-coded
struct.MovieMetadata.CurrFrame=1;
struct.MovieMetadata.Increment=1;

struct.SpecifyTrials='';
struct.ExampleCondition='';
struct.ExampleSubject='';
struct.ExampleTrial='';

struct.Components.Text={}; % Includes name & ID
struct.Components.Parent={}; % Includes name & ID
struct.Components.Children={}; % Includes name & ID
struct.Components.ModifiedProperties={}; % The names of the properties that have been modified

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

filename=['Plot_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');