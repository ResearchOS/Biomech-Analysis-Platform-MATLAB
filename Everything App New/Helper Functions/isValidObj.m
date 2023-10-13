function [bool] = isValidObj(obj)

%% PURPOSE: TEST THAT AN ARGUMENT IS A VALID OBJECT.
bool = false;

if ~isstruct(obj)
    return;
end

if ~isfield(obj,'UUID')
    return;
end

if ~isUUID(obj.UUID)
    return;
end

if ~isfield(obj, 'OutOfDate')
    return;
end

bool = false;