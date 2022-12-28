function [struct]=createProjectStruct(fig,name)

%% PURPOSE: CREATE A NEW PROJECT STRUCT

slash=filesep;

struct.Type='Project';

struct.Name=name;

id=createID(fig,'Project');
struct.ID=id; % Immutable

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Description='';

struct.Variables={};

struct.Logsheet={};

struct.Plots={};

struct.StatsTable={};

struct.PubTable={};

struct.Process={};

struct.Components={};

struct.DataPath='';

struct.CodePath='';

struct.Visible=true; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true; % If true, this will show up as having dependencies that need to be updated

struct.Checked=true; % If true, the uitreenode checkbox will be checked. If false, it will be unchecked.

filename=['Project_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

commonPath=getCommonPath(fig);

classFolder=[commonPath slash 'Project'];

filepath=[classFolder slash filename];

% save(filepath,'struct','-v6');

json=jsonencode(struct,'PrettyPrint',true);

fid=fopen([filepath '.json'],'w');
fprintf(fid,'%s',json);
fclose(fid);