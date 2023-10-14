function [abstractUUID] = getAbstractID(instanceUUID)

%% PURPOSE: GIVEN AN INSTANCE UUID, RETURN THE ABSTRACT UUID. THIS IS A PURE CONVENIENCE FUNCTION.

[type, abstractID] = deText(instanceUUID);
abstractUUID = genUUID(type, abstractID);