function [] = setPR_VROutOfDate(src, uuid, outOfDateBool, prop)

%% PURPOSE: SET OUTOFDATE OF ALL DEPENDENT PR & VR OF THE SPECIFIED PR UUID
% prop: True when I should propagate the changes to all downstream
% dependent PR's.

global conn;

%%% ATTEMPT WITH ALL OBJECTS DIGRAPH
% G = getAllObjLinks();
% G2 = getAllObjsLinksInContainer(G, uuid, 'down');
% if prop
%     uuids = G2.Nodes.Name;
% elseif ~prop
%     uuids = successors(G2,uuid);
% end
% currDate = char(datetime('now'));
% if outOfDateBool==1
% 
%     for i=1:length(uuids)
%         type = deText(uuids{i});
%         tablename = getTableName(type, true);
%         sqlquery = ['UPDATE ' tablename ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuids{i} ''';'];
%         execute(conn, sqlquery);
%     end
% 
% elseif outOfDateBool==0
% 
%     for i=1:length(uuids)
%         anyOutOfDateBool = false; % False if none of the predecessors are out of date.
%         preds = predecessors(G2,uuids{i});   
% 
%         for j = 1:length(preds)
%             type = deText(preds{j});
%             tablename = getTableName(type, true);
%             sqlquery = ['SELECT OutOfDate FROM ' tablename ' WHERE UUID = ''' preds{j} ''';'];
%             t = fetch(conn, sqlquery);
%             t = table2MyStruct(t);
%             if t.OutOfDate==1
%                 anyOutOfDateBool = true; % At least one of the predecessors is out of date.
%                 break;
%             end
%         end
% 
%         if ~anyOutOfDateBool
%             type = deText(uuids{i});
%             tablename = getTableName(type, true);
%             sqlquery = ['UPDATE ' tablename ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuids{i} ''';'];
%             execute(conn, sqlquery);
%         end
% 
%     end
% end






if ~isempty(src)
    fig=ancestor(src,'figure','toplevel');
else
    fig = '';
end

[type] = deText(uuid);
assert(isequal(type,'PR'));

if nargin==3
    prop = false;
end

if ~isempty(fig)
    G = getappdata(fig,'digraph');
    if isempty(G) || prop
        G = refreshDigraph(fig);
    end
else
    G = refreshDigraph();
end

if ~prop
    depPR = {uuid}; % One UUID to just update the current PR.
    ordDepList = depPR;
else
    [~, depPR] = getDeps(G,'down',uuid); % The downstream PR's.
    depPR = [{uuid}; depPR]; % Add the UUID to the front of the list of dependencies
    containerUUID = getCurrent('Current_Analysis');
    list = getRunList(containerUUID, G);
    listIdx = ismember(list(:,1),depPR);
    ordDepList = list(listIdx,1); % Ordered dependency list
end

% Get all of the output variables from the downstream PR's.
sqlquery = ['SELECT VR_ID, PR_ID FROM PR_VR'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
depsIdx = ismember(t.PR_ID,depPR);
depVR_Out = t.VR_ID(depsIdx); % Downstream dependent VR's
depPR_Out = t.PR_ID(depsIdx); % Downstream dependent PR's in same order.

% Get all of the input variables from the downstream PR's.
sqlquery = ['SELECT VR_ID, PR_ID FROM VR_PR'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
depsIdx = ismember(t.PR_ID,depPR); % Index of the PR's of interest (dependencies)
depPR_In = t.PR_ID(depsIdx); % The downstream PR in same order as var
depVR_In = t.VR_ID(depsIdx); % The input vars to all downstream PR's

currDate = char(datetime('now'));

%% If putting PR out of date = true, then all PR & VR downstream are out of date automatically.
tablenamePR = getTableName('PR',true);
tablenameVR = getTableName('VR',true);

if outOfDateBool    
    for i=1:length(depPR)
        uuid = depPR{i};
        sqlquery = ['UPDATE ' tablenamePR ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuid ''';'];
        execute(conn, sqlquery);
    end

    tablenameVR = getTableName('VR',true);
    for i=1:length(depVR_Out)
        uuid = depVR_Out{i};
        sqlquery = ['UPDATE ' tablenameVR ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuid ''';'];
        execute(conn, sqlquery);
    end
end

%% If putting PR out of date = false, then need to check if all input VR to each out-of-date PR is out of date.
% If they are all up to date with this change, then the PR is up to date,
% and all of its output VR's are up to date, and so on.
if ~outOfDateBool  
    for i=1:length(ordDepList)

        % Get the outOfDate from all variables.
        sqlquery = ['SELECT UUID, OutOfDate FROM Variables_Instances'];
        varsFromTable = fetch(conn, sqlquery);
        varsFromTable = table2MyStruct(varsFromTable);

        % Get all of the input variables to this PR. If they're all outOfDate=false, then PR is outOfDate = false.
        uuid = ordDepList{i};
        inVarsIdx = ismember(depPR_In,uuid); % Idx of this PR
        inVars = depVR_In(inVarsIdx);

        % Get the outOfDate for these input variables.
        outOfDateIdx = ismember(varsFromTable.UUID, inVars);
        outOfDate = varsFromTable.OutOfDate(outOfDateIdx);

        outVarsIdx = ismember(depPR_Out,uuid);
        outVars = depVR_Out(outVarsIdx);

        % At least one input variable out of date. Set the PR and all its
        % output variables to be outOfDate = true.
        outOfDateScalar = 0;
        if any(outOfDate==1)
            outOfDateScalar = 1;            
        end

        % PR OutOfDate
        sqlquery = ['UPDATE ' tablenamePR ' SET OutOfDate = ' num2str(outOfDateScalar) ', Date_Modified = ''' currDate ''' WHERE UUID = ''' uuid ''';'];
        execute(conn, sqlquery);

        if isempty(outVars)
            continue;
        end

        varsStr = '(';
        for j=1:length(outVars)
            varsStr = [varsStr '''' outVars{j} ''', '];
        end
        varsStr = [varsStr(1:end-2) ')'];        

        % VR OutOfDate
        sqlquery = ['UPDATE ' tablenameVR ' SET OutOfDate = ' num2str(outOfDateScalar) ', Date_Modified = ''' currDate ''' WHERE UUID IN ' varsStr ';'];
        execute(conn, sqlquery);
        
    end
end