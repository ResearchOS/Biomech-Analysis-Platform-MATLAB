function [struct]=createStatsTableStruct(fig,name)

%% PURPOSE: CREATE A NEW STATS TABLE STRUCT

struct.Name=name;

id=getID(fig,'StatsTable');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.SpecifyTrials='';

struct.RepetitionVariables={};
struct.IsMultiVariable=[];

struct.DataVariables={};

struct.SummaryFunctions={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

filename=['StatsTable_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');