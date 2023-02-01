function []=createPubTableStruct(name,id)

%% PURPOSE: CREATE A NEW PUBLICATION TABLE STRUCT

struct.Name=name;

struct.Class='PubTable';

if nargin==1
    id=createID('Process');
end
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.SpecifyTrials='';

struct.NumRows=1;
struct.NumCols=1;

struct.Versions={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass('PubTable',struct);

assignToProject(struct);