function [struct,piStruct]=createComponentStruct_PS(piStruct,psid)

%% PURPOSE: CREATE A PROJECT-SPECIFIC COMPONENT STRUCT

struct.Name=piStruct.Name;

struct.Class='Component';

if nargin==1 || isempty(psid)
    psid=createPSID(piStruct.Text, 'Component');
end
struct.ID=psid;

if isequal(struct.Name,'Axes')
    struct.FixedFrame=1; % 1 to make axes always constant in movies, 0 not to.
    struct.FixedPosition=''; % Only used if 'FixedFrame' is 0. If char, is a variable name. If double, should be a 1x2 or 1x3.
end

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

struct.InputVariables={};
struct.InputSubvariables={};

struct.Tags={};

if isequal(struct.Name, 'Axes')
    struct.Position=[1 1 1]; % By default axes subplot is the whole figure. Can also be a 1x4 to manually specify position
end

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this variable will be highlighted as needing to be updated.

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Visible=true;

struct.Text=[piStruct.Text '_' psid];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass_PS('Component',struct);

% piStruct=assignVersion(piStruct,struct);