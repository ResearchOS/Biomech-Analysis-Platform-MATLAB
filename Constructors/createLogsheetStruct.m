function [struct]=createLogsheetStruct(fig,name)

%% PURPOSE: CREATE A NEW LOGSHEET STRUCTURE
% Properties:

% file path:
% file name: 
% date created: 
% date modified:
% id: 
% project names: 
% description: 
% variables:
% level:
% datatype: 
% specifyTrials:

struct.Name=name;

id=createID(fig,'Logsheet');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.SpecifyTrials=''; % Which set of data to pull the variables out from?

struct.DataPath=''; % Which dataset is this describing?

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

filename=['Logsheet_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');