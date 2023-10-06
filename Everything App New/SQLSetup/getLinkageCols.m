function [col1, col2] = getLinkageCols(uuids)

%% PURPOSE: RETURN THE LINKAGE COLUMN HEADER NAMES GIVEN TWO UUID'S.

col1 = '';
col2 = '';

if ~iscell(uuids)
    return;
end

if length(uuids)~=2
    return;
end

[types] = deText(uuids);

if isequal(types{1},types{2})
    types{1} = ['Parent_' types{1}];
    types{2} = ['Child_' types{2}];
end

types{1} = [types{1} '_ID'];
types{2} = [types{2} '_ID'];

col1 = types{1};
col2 = types{2};