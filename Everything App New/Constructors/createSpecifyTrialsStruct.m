function []=createSpecifyTrialsStruct(fig, name)

%% PURPOSE: CREATE A PROJECT-INDEPENDENT SPECIFY TRIALS STRUCT

struct.Name=name;

struct.Type='SpecifyTrials';

if nargin<3
    id=createID(fig,'SpecifyTrials');
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

handles=getappdata(fig,'handles');
currentProject=handles.Projects.projectsLabel.Text;

struct.Project={currentProject};

% AND logic. All criteria must be met for this specify trials condition to return true.
struct.Logsheet_Headers={};
struct.Logsheet_Logic={};
struct.Logsheet_Value={};
struct.Data_Variables={};
struct.Data_Logic={};
struct.Data_Value={};

struct.Archived=false;

struct.Checked=true;

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent='';

saveClass(fig,'SpecifyTrials',struct)

%% Assign the newly create specifyTrials struct to the current project
assignToProject(fig,struct,'SpecifyTrials');