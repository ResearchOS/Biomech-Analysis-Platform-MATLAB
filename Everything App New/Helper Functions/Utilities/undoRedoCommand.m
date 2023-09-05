function [undoquery] = undoRedoCommand(sqlquery)

%% PURPOSE: GET THE COMMAND TO UNDO AN SQL COMMAND
% DELETE syntax: DELETE FROM tablename WHERE columnName = value;
% INSERT syntax: INSERT INTO tablename (col1,...,coln) VALUES (val1,...,valn);
% UPDATE syntax: UPDATE tablename SET column1 = value1, column2 = value2 WHERE col = value;

global conn;

if ~isequal(sqlquery(end),';')
    sqlquery = [sqlquery ';'];
end

if isequal(sqlquery(1:6),'DELETE')
    whereIdx = strfind(sqlquery,' WHERE ');
    tablename = sqlquery(13:whereIdx-1); % The tablename
    condStr = sqlquery(whereIdx+7:end-1); % The WHERE condition.
    selectquery = ['SELECT * FROM ' tablename ' WHERE ' condStr];
    t = fetch(conn, selectquery);
    t = table2MyStruct(t);    
    undoquery = struct2SQL(tablename, t, 'INSERT');
end

if isequal(sqlquery(1:6),'INSERT')     
    openParensIdx = strfind(sqlquery,'(');
    closeParensIdx = strfind(sqlquery,')'); 
    tablename = sqlquery(13:openParensIdx(1)-2); % tablename
    colStr = strrep(sqlquery(openParensIdx(1):closeParensIdx(1)),' ','');    
    colStrSplit = strsplit(colStr,',');
    colStrSplit{1}(1) = '';
    colStrSplit{end}(end) = '';
    apostropheIdx = strfind(sqlquery,'''');
    condStr = '';
    for i=1:length(colStrSplit)
        condStr = [condStr colStrSplit{i} ' = ' sqlquery(apostropheIdx(1):apostropheIdx(2)) ' AND '];
        apostropheIdx(1:2) = [];
    end
    condStr = [condStr(1:end-5) ';'];

    undoquery = ['DELETE FROM ' tablename ' WHERE ' condStr];
    
end

if isequal(sqlquery(1:6),'UPDATE')
    setIdx = strfind(sqlquery, ' SET ');
    tablename = sqlquery(8:setIdx-1);
    whereIdx = strfind(sqlquery, ' WHERE ');
    if isempty(whereIdx)
        whereIdx = length(sqlquery)-1;
    end
    % Swap the values of the WHERE conditions and the SET column conditions
    whereConds = sqlquery(whereIdx+7:end-1);
    whereLogic = 'AND';
    if contains(sqlquery(whereIdx+7:end),' OR ')
        whereLogic = 'OR';
    end

    % Get the SET columns and conditions of the original statement.
    % This becomes the WHERE conditions for the undo statement.
    eachColVal = strsplit(sqlquery(setIdx+5:whereIdx),',');
    whereCondsStr = '';
    for i=1:length(eachColVal)        
        whereCondsStr = [whereCondsStr strrep(eachColVal{i},' ','') ' ' whereLogic ' '];
    end
    whereCondsStr = whereCondsStr(1:end-(length(whereLogic)+3));

    if ~isempty(whereConds)
        setCondsStr = strrep(whereConds,' ','');
        setCondsStr = strrep(setCondsStr,whereLogic,', ');
    else % No WHERE condition
        error('No WHERE condition for UPDATE statement not implemented yet.');
    end

    if whereIdx == length(sqlquery)-1 % No WHERE statement
        undoquery = ['UPDATE ' tablename ' SET ' setCondsStr];
    else
        undoquery = ['UPDATE ' tablename ' SET ' setCondsStr ' WHERE ' whereCondsStr];
    end
end