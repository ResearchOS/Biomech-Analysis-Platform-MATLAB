function [struct]=createProjectStruct(fig,name)

%% PURPOSE: CREATE A NEW PROJECT STRUCT

struct.Name=name;

id=getID(fig,'Project');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

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

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

filename=['Project_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');