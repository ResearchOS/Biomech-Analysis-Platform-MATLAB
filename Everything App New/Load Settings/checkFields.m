function [struct, modified] = checkFields(struct)

%% PURPOSE: CHECK THAT THIS STRUCT HAS ALL OF ITS REQUIRED FIELDS. IF NOT, INSERT THOSE FIELDS.
% In the future, this will also check for the accuracy of the contents of a
% field.

modified = false;

%% Linkage matrix
if isfield(struct,'Links') && length(fieldnames(struct))<=2
    return;
end

if ~isfield(struct,'UUID')
    error('Missing UUID!');
end

%% Class objects.
[name, abstractID, instanceID]=deText(struct.UUID);
instanceBool=true; % Init true
if isempty(instanceID)
    instanceBool = false;    
end

saveObj = false; % Don't save the object being created.
compStruct = createNewObject(instanceBool, struct.Class, '', abstractID, instanceID, saveObj);
compFieldnames = fieldnames(compStruct);
structFieldnames = fieldnames(struct);

missingFieldsIdx = ~ismember(compFieldnames,structFieldnames);

if any(missingFieldsIdx)

    % 1. Identify which fields are missing from the actual data struct.    
    missingFieldnames = compFieldnames(missingFieldsIdx);
    
    % 2. Put those fields from the comparison struct into the actual data struct. 
    for i=1:length(missingFieldnames)
        fldName = missingFieldnames{i};
        struct.(fldName) = compStruct.(fldName);
    end
    modified = true;
end