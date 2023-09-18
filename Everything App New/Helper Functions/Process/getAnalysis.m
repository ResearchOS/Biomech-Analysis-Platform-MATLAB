function [anUUID] = getAnalysis(origUUID, anUUID)

%% PURPOSE: GET WHICH ANALYSES THIS OBJECT IS PART OF. CAN RETURN MORE THAN ONE!
% WORKS FOR ALL OBJECTS BESIDES LOGSHEETS, PROJECTS, AND ANALYSIS.

global conn;

uuid = origUUID;
type = deText(uuid);

if ismember(type,{'PJ'})
    anUUID = {};
    return;
end

if nargin==1
    anUUID = {};
end

% Analysis
if isequal(type,'AN') && nargin==1
    anUUID = uuid;
    return;
end

class = className2Abbrev(type);

%% View
if isequal(class,'View')
    % Get AN from AN_VW table.
    uuidStr = getCondStr(uuid);
    sqlquery = ['SELECT AN_ID FROM AN_VW WHERE VW_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    anUUID = t.AN_ID;
    return;
end

%% Variable
if isequal(class,'Variable')    
    % Get PR from PR_VR table. Still need to look at hard-coded input variables.
    uuidStr = getCondStr(uuid);
    sqlquery = ['SELECT PR_ID FROM PR_VR WHERE VR_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        t.PR_ID = {};
    end
    uuid_PR = t.PR_ID;
    if isempty(uuid_PR)
        return; % Variable not assigned to anything, so no anUUID.
    end
    class = 'Process';
end

%% Process
anUUID_PR = {}; pgUUID_PR={}; pgUUID_PG = {};
if isequal(class,'Process')    
    % Check AN_PR table. If found, still don't end here because maybe in
    % one AN it's part of a group, and in another it's not.
    if ~exist('uuid_PR','var')
        uuid_PR = origUUID;
    end
    uuidStr = getCondStr(uuid_PR);
    sqlquery = ['SELECT AN_ID FROM AN_PR WHERE AN_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        anUUID_PR = {};
    else
        anUUID_PR = t.AN_ID; % Analyses obtained from PR's
    end
    if isempty(anUUID_PR)
        anUUID_PR = {};
    end
    if ~iscell(anUUID_PR)
        anUUID_PR = {anUUID_PR};
    end

    % Check PG_PR table    
    sqlquery = ['SELECT PG_ID FROM PG_PR WHERE PR_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        pgUUID_PR = {};
    else
        pgUUID_PR = t.PG_ID;
    end
    if isempty(pgUUID_PR)
        pgUUID_PR = {};
    end
    if ~iscell(pgUUID_PR)
        pgUUID_PR = {pgUUID_PR};
    end
end

%% ProcessGroup
if ismember(class,{'Process','ProcessGroup'})
    % Check AN_PG table.
    if ~isempty(pgUUID_PR)
        uuid = pgUUID_PR;
    end
    uuidStr = getCondStr(uuid);
    sqlquery = ['SELECT AN_ID FROM AN_PG WHERE PG_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        anUUID_PG = {};
    else
        anUUID_PG = t.AN_ID;
    end
    if isempty(anUUID_PG)
        anUUID_PG = {};
    end
    if ~iscell(anUUID_PG)
        anUUID_PG = {anUUID_PG};
    end

    % Check PG_PG table.    
    sqlquery = ['SELECT Parent_PG_ID FROM PG_PG WHERE Child_PG_ID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        pgUUID_PG = {};
    else
        pgUUID_PG = t.Parent_PG_ID;
    end
    if isempty(pgUUID_PG)
        pgUUID_PG = {};
    end
    if ~iscell(pgUUID_PG)
        pgUUID_PG = {pgUUID_PG};
    end
        
end

%% Recursively run, or finish if AN found.
anUUID = unique([anUUID_PG; anUUID_PR],'stable');
inUUID = unique([pgUUID_PG; pgUUID_PR],'stable');
if isempty(anUUID)
    [anUUID] = getAnalysis(inUUID, anUUID);
end


end