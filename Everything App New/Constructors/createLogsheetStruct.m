function [struct]=createLogsheetStruct(fig,name,id)

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

struct.Type='Logsheet';

if nargin<3
    id=createID(fig,'Logsheet');
end
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

computerID=getComputerID();

struct.Description='';

struct.LogsheetPath.(computerID)='';

struct.NumHeaderRows=-1;

struct.SubjectCodenameHeader='';

struct.TargetTrialIDHeader='';

%% NOTE: Need to implement data type-specific headers.

handles=getappdata(fig,'handles');
currentProject=handles.Projects.projectsLabel.Text;

struct.Project={currentProject};

struct.SpecifyTrials=''; % Which set of data to pull the variables out from?

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.Visible=true;

struct.OutOfDate=true;

struct.Checked=true; % Only one logsheet can be checked at any one time. Checked indicates that this is the currently used logsheet.

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

struct.Headers={}; % The headers for the current logsheet.
struct.Level={}; % Trial or subject
struct.Type={}; % Char or double

saveClass(fig,'Logsheet',struct);

classVar=getappdata(fig,'Logsheet');

if isempty(classVar)
    classVar=struct;
else
    classVar(end+1)=struct;
end

setappdata(fig,'Logsheet',classVar);

%% Assign the newly created logsheet struct to the current project struct.
assignToProject(fig,struct,'Logsheet');