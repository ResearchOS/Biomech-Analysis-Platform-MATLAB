function [names] = getName(uuids)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME
% NOTE: In the future, can check if there's any duplicate UUID's to speed
% this function up.

if ischar(uuids)
    uuids = {uuids};
end

[m, n] = size(uuids);
uuids = reshape(uuids,m*n,1);

names = cell(size(uuids));
for i=1:length(uuids)
    uuid = uuids{i};
    if isempty(uuid)
        names{i}='';
        continue;
    end
    struct = loadJSON(uuid);

    names{i} = struct.Text;
end

names = reshape(names,m,n);