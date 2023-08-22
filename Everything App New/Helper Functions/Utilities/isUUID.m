function [bool] = isUUID(uuid)

%% RETURN TRUE IF THE UUID IS IN THE PROPER FORMAT. RETURN FALSE OTHERWISE.
bool = true;

[type, abstractID, instanceID] = deText(uuid);

%% Type
types = {'LG','PJ','PR','PG','VR','AN','ST'};
if ~ismember(type,types)
    bool = false;
    return;
end

%% Abstract ID
if length(abstractID)~=6
    bool = false;
    return;
end

try
    a = hex2dec(abstractID);
catch
    bool = false;
    return;
end

%% Instance ID
if ~isempty(instanceID) && length(instanceID)~=3
    bool = false;
    return;
end

if ~isempty(instanceID)
    try
        a = hex2dec(instanceID);
    catch
        bool = false;
        return;
    end
end