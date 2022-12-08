function []=createComponentStruct(fig,name)

%% PURPOSE: CREATE A NEW COMPONENT STRUCT

struct.Name=name;

id=createID(fig,'Component');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.DefaultInputVariables={};
struct.InputVariables={};

struct.ModifiedDefaultProperties={}; % List of property names to have the defaults modified for
struct.ModifiedPropertyValues={}; % The new default values of those properties

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

filename=['Process_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');