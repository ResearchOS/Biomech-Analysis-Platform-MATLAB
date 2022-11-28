function []=createPubTableStruct(fig,name)

%% PURPOSE: CREATE A NEW PUBLICATION TABLE STRUCT

struct.Name=name;

id=getID(fig,'Process');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

struct.Description='';

struct.Projects={};

struct.SpecifyTrials='';

struct.NumRows=1;
struct.NumCols=1;

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

filename=['Process_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');