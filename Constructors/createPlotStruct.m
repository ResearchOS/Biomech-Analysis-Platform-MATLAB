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

id=getID(fig,'Plot');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

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

filename=['Plot_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');