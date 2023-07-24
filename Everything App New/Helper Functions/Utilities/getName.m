function [names] = getName(uuids)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME

if ischar(uuids)
    uuids = {uuids};
end

names = cell(size(uuids));
for i=1:length(uuids)
    uuid = uuids{i};
    struct = loadJSON(uuid);

    names{i} = struct.Text;
end