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

struct.Type='Variable';

id=createID(fig,'Variable');
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

struct.SpecifyTrials='';

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

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass(fig,'Variable',struct);

classVar=getappdata(fig,'Variable');

if isempty(classVar)
    classVar=struct;
else
    classVar(end+1)=struct;
end

setappdata(fig,'Variable',classVar);

%% Assign the newly created variable struct to the current project struct.
assignToProject(fig,struct,'Variable');