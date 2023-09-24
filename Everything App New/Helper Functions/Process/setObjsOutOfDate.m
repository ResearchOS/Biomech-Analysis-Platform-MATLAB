function [] = setObjsOutOfDate(src, uuid, outOfDateBool, prop)

%% PURPOSE: SET OUTOFDATE OF ALL DEPENDENT PR & VR OF THE SPECIFIED PR UUID
% prop: True when I should propagate the changes to all downstream
% dependent PR's.

global conn globalG;

%%% ATTEMPT WITH ALL OBJECTS DIGRAPH
% if prop
uuids = getReachableNodes(globalG,uuid);    
% elseif ~prop
%     uuids = successors(globalG,uuid);
% end
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
        anyOutOfDateBool = false; % False if none of the predecessors are out of date.
        preds = predecessors(G2,uuids{i});  
        
        outOfDates = 

        for j = 1:length(preds)
            type = deText(preds{j});
            tablename = getTableName(type, true);
            sqlquery = ['SELECT OutOfDate FROM ' tablename ' WHERE UUID = ''' preds{j} ''';'];
            t = fetch(conn, sqlquery);
            t = table2MyStruct(t);
            if t.OutOfDate==1
                anyOutOfDateBool = true; % At least one of the predecessors is out of date.
                break;
            end
        end

        if ~anyOutOfDateBool
            type = deText(uuids{i});
            tablename = getTableName(type, true);
            sqlquery = ['UPDATE ' tablename ' SET OutOfDate = true, Date_Modified = ''' currDate ''' WHERE UUID = ''' uuids{i} ''';'];
            execute(conn, sqlquery);
        end

    end
end