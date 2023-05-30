function [struct,piStruct]=createPlotStruct_PS(piStruct,psid)

%% PURPOSE: CREATE A PROJECT-SPECIFIC PLOT STRUCT

struct.Name=piStruct.Name;

struct.Class='Plot';

struct.Level='T';

struct.Multi='T';

if nargin==1 || isempty(psid)
    psid=createPSID(piStruct.Text, 'Plot');
end
struct.ID=psid;

struct.MFileName=[piStruct.Text '_' struct.ID];

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT';
struct.CreatedBy=user;

user2=user;
struct.LastModifiedBy=user2;

struct.Description='';

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.SpecifyTrials='';

struct.Tags={};

struct.AlignEvent=''; % If plotting multiple trials on one plot, this variable (char)/hard-coded value (double) specifies (if not empty) the event (index) to X-axis align the data by

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

% This will contain all of the modified properties for all components in the plot. 
% So, the fieldnames will be PS component names.
% Those fields' fieldnames will be those components' properties' names.
struct.Properties={};

% struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[piStruct.Text '_' psid];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass_PS('Plot',struct);

% piStruct=assignVersion(piStruct,struct);