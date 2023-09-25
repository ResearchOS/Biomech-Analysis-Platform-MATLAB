function [] = setObjsOutOfDate(src, uuid, outOfDateBool, prop)

%% PURPOSE: SET OUTOFDATE OF ALL DEPENDENT OBJECTS FOR THE SPECIFIED UUID
% prop: True when I should propagate the changes to all downstream
% dependent PR's.

global conn globalG;

uuids = getReachableNodes(globalG,uuid);    
currDate = char(datetime('now'));
if outOfDateBool==1
    uuidsIdx = ismember(globalG.Nodes.Name,uuids);
    globalG.Nodes.OutOfDate(uuidsIdx) = true;
    for i=1:length(uuids)
        type = deText(uuids{i});
        tablename = getTableName(type, true);
        sqlquery = ['UPDATE ' tablename ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuids{i} ''';'];
        execute(conn, sqlquery);
    end

elseif outOfDateBool==0

    for i=1:length(uuids)
        subG = getSubgraph(globalG, uuids{i},'up');
        nodesIdx = ismember(globalG.Nodes.Name, subG.Nodes.Name);
        anyOutOfDateBool = false;
        if any(nodesIdx==1)
            anyOutOfDateBool = true;
        end

        if ~anyOutOfDateBool
            type = deText(uuids{i});
            tablename = getTableName(type, true);
            sqlquery = ['UPDATE ' tablename ' SET OutOfDate = false, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuids{i} ''';'];
            execute(conn, sqlquery);
            uuidIdx = ismember(globalG.Nodes.Name,uuids{i});
            globalG.Nodes.OutOfDate(uuidIdx) = false;
        end

    end
end