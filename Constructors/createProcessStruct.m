function [struct]=createProcessStruct(fig,name)

%% PURPOSE: CREATE A NEW PROCESS FUNCTION STRUCTURE

struct.Name=name;

id=getID(fig,'Process');
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate; % Reflects when metadata changed AND when the .m file was saved. Save time of .m file doesn't update until interaction

struct.Description='';

struct.Projects={};

struct.SpecifyTrials='';

struct.InputVariables={};
struct.OutputVariables={};

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

% If true, this function will be highlighted as needing to be re-run.
% Ways to be out of date:
% 1. Any of the input variables' DateModified is after any of the output variables' DateModified
% 2. The function's .m file (and any subfunctions?) DateModified is after any of the input or output variables' DateModified
struct.OutOfDate=true;

filename=['Process_' name '_' id '.mat'];

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

save(filename,'struct','-v6');