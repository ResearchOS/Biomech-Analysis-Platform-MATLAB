function [struct] = initializeCommonStructFields(instanceBool, class, name, abstractID, instanceID, struct)

%% When creating a new object for the first time, ...
% OR copying one object to another. Runs this, then initializes (or copies)
% the object type-specific fields

if exist('abstractID','var')~=1
    abstractID = '';
end

if exist('instanceID','var')~=1
    instanceID = '';
end

% Get the current analysis
projectSettingsPath = getProjectSettingsFile();
projectSettings = loadJSON(projectSettingsPath);
currAnalysis = projectSettings.Current_Analysis;

currDate = datetime('now');
struct.DateCreated = currDate;
struct.DateModified = currDate;

struct.Name = name;

struct.Class = class;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Description='';

if ~isequal(class,'Analysis')
    if ~isfield(struct,'Analysis')
        struct.Analysis = {currAnalysis};
    else
        struct.Analysis = [struct.Analysis; {currAnalysis}];
    end
end

struct.OutOfDate=true;

if isempty(abstractID)
    abstractID=createID_Abstract(class);
end

if isempty(instanceID) && instanceBool
    instanceID=createID_Instance(abstractID, class);
end

struct.UUID = genUUID(class, abstractID, instanceID);

end

