function [t] = fetchQuery(sqlquery,charFmt, resultFormat)

%% PURPOSE: RUN THE SQL SELECT QUERY AND FORMAT THE OUTPUT.
% Output is ALWAYS a cell, empty or not, unless.

global conn;

if nargin==1
    charFmt = 'cell'; % Other option: 'char'
end

if nargin<=2
    resultFormat = 'cell'; % Other option: 'struct'
end

assert(contains(sqlquery,'SELECT'));
assert(contains(sqlquery,'FROM'));

t = fetch(conn, sqlquery);
t = table2MyStruct(t, resultFormat);

selIdx = strfind(sqlquery,'SELECT');
fromIdx = strfind(sqlquery,'FROM');

cols = sqlquery(selIdx+6:fromIdx-1);
cols = strrep(cols, ' ', ''); % Remove the white space (can SQL columns have spaces?)

colNames = strsplit(cols,',');

%% If '*' is used instead of column names.
if isequal(colNames,{'*'})
    % Get the table name
    spaceIdx = strfind(sqlquery,' '); % Idx of all spaces in the SQL query
    beforeTableNameSpaceNum = find(ismember(spaceIdx,fromIdx+4)); % The space number of the space after 'FROM'
    tablenameStartIdx = spaceIdx(beforeTableNameSpaceNum)+1;
    if beforeTableNameSpaceNum==length(spaceIdx)
        if isequal(sqlquery(end),';')
            tablenameEndIdx = length(sqlquery)-1; % With a semicolon
        else
            tablenameEndIdx = length(sqlquery); % Assumes no semicolon
        end
    else
        tablenameEndIdx = spaceIdx(beforeTableNameSpaceNum+1)-1;
    end
    tablename = sqlquery(tablenameStartIdx:tablenameEndIdx);
    info = sqlfind(conn,tablename);
    colNames = cellstr(info.Columns{1});
end

%% Ensure that everything is a cell or char or numeric. No strings!
% NOTE: ALWAYS ENSURE THAT EVERY FIELD IS RETURNED AS EMPTY CELL IF NOT
% PRESENT, OR AS THE PROPER TYPE (SPECIFIED BY ALL COL TYPES) IF IT IS
% PRESENT.

% SHOULD COMPLEMENT/ALREADY BE DONE IN TABLE2MYSTRUCT?
% colTypes = allColTypes();
% colTypeFldNames = fieldnames(colTypes);
for i=1:length(colNames)

    colName = colNames{i};

    if ~isfield(t,colName)
        t.(colName) = {};
        continue;
    end

    if ischar(t.(colName)) && isequal(charFmt,'cell')
        t.(colName) = {t.(colName)};
    end
        

    % for j=1:length(colTypeFldNames)
    %     if ismember(colName,colTypes.(colTypeFldNames{j}))
    % 

    % if ~iscell(t.(colName))
    %     if ischar(t.(colName))
    %         t.(colName) = {t.(colName)};
    %     elseif isstring(t.(colName))
    %         t.(colName) = cellstr(t.(colName));
    %     end
    % end
    % 
    % assert(~isstring(t.(colName)));  
    
end