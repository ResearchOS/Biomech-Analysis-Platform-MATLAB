function [t] = fetchQuery(sqlquery)

%% PURPOSE: RUN THE SQL SELECT QUERY AND FORMAT THE OUTPUT.
% Output is ALWAYS a cell, empty or not.

global conn;

assert(contains(sqlquery,'SELECT'));
assert(contains(sqlquery,'FROM'));

t = fetch(conn, sqlquery);
t = table2MyStruct(t);

selIdx = strfind(sqlquery,'SELECT');
fromIdx = strfind(sqlquery,'FROM');

cols = sqlquery(selIdx+6:fromIdx-1);
cols = strrep(cols, ' ', ''); % Remove the white space (can SQL columns have spaces?)

colNames = strsplit(cols,',');

for i=1:length(colNames)

    colName = colNames{i};

    if ~isfield(t,colName)
        t.(colName) = {};
    elseif ~iscell(t.(colName))
        if ischar(t.(colName))
            t.(colName) = {t.(colName)};
        end
    end

    assert(iscell(t.(colName)) || ischar(t.(colName)) || isnumeric(t.(colName)));
    assert(~isstring(t.(colName)));
    
end