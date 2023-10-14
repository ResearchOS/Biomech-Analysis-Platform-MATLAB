function [bool] = isInstance(uuid)

%% PURPOSE: RETURN TRUE IF THE UUID IS AN INSTANCE, FALSE IF ABSTRACT.

bool = true;
[type, abstractID, instanceID] = deText(uuid);
if isempty(instanceID)
    bool = false;
end