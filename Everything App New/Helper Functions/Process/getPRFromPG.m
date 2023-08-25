function [pr] = getPRFromPG(pg, prevPR)

%% PURPOSE: GIVEN ONE OR MORE PROCESSING GROUPS, RETURN AN UNORDERED LIST OF ALL THE PROCESSING FUNCTIONS IN THOSE GROUPS.
global conn;

pr = {};

if ~iscell(pg)
    pg = {pg};
end

for i=1:length(pg)    
    sqlquery = ['SELECT PR_ID FROM PG_PR WHERE UUID = ''' pg{i} ''';'];
    prs = fetch(conn, sqlquery);
    prs = cellstr(prs.PR_ID);
    [types] = deText(prs);
    for j = 1:length(prs)
        if isequal(types,'PG')
            prsRec = getPRFromPG(prs{j}, pr);
            pr = [pr; prsRec];
        else
            pr = [pr; prs];
        end
    end
end