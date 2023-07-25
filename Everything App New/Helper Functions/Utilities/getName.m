function [names] = getName(uuids)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME

if ischar(uuids)
    uuids = {uuids};
end

[m, n] = size(uuids);
uuids = reshape(uuids,m*n,1);

names = cell(size(uuids));
for i=1:length(uuids)
    uuid = uuids{i};
    struct = loadJSON(uuid);

    names{i} = struct.Text;
end

names = reshape(names,m,n);