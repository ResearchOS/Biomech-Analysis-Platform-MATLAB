function [struct]=createVariableStruct(fig,name)

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

id=createID(fig,'Variable');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.SpecifyTrials='';

% Automatically set the first time that this variable is computed. 
% Thereafter, when adding the Variable to Process functions, I should check that the same data path is used. 
% Can't mix datasets within the same function!
struct.DataPath='';

struct.InputToFunctions={};
struct.OutputFromFunctions={};

% For argument validation
struct.VariableType=''; % What type is this variable
struct.VariableSize=[]; % What is the size of this variable
% struct.VariableDimLabels={}; % What is the description of each dimension of the variable

struct.InputToPlots={};
struct.InputToComponents={};
struct.InputToStatsTables={};
struct.InputToPubTables={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

filename=['Variable_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');