function [struct,piStruct]=createProcessStruct_PS(piStruct,psid)

%% PURPOSE: CREATE A PROJECT-SPECIFIC PROCESS FUNCTION STRUCT

struct.Name=piStruct.Name;

struct.Class='Process';

if nargin==1 || isempty(psid)
    psid=createPSID(piStruct.Text, 'Process');
end
struct.ID=psid;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;
struct.DateLastRan=[]; % The last time that this function was run. Pending highlighting to show out-of-date functions, this is a quick and dirty way to tell if I already ran the function.

user='MT';
struct.CreatedBy=user;

user2=user;
struct.LastModifiedBy=user2;

struct.Description='';

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.SpecifyTrials='';

% Project-specific versions of variables being input & output from this
% process function.
struct.InputVariables={};
struct.InputSubvariables={};
struct.OutputVariables={};

struct.Tags={};

struct.UsedInGroups={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[piStruct.Text '_' psid];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass_PS('Process',struct);

% piStruct=assignVersion(piStruct,struct);