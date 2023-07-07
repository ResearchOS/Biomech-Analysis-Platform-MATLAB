function []=initAbstract_Objs()

%% PURPOSE: ENSURE THAT EVERY OBJECT INSTANCE HAS A CORRESPONDING ABSTRACT OBJECT
classNames = className2Abbrev('list');

for i=1:length(classNames)

    class = classNames{i};      

    % Existing abstract files
    abstractFilenames = getClassFilenames(class, false);  
    [~, abs_abstractIDs] = deText(abstractFilenames);    

    % Existing instance files (removing duplicate abstract ID's)
    instanceFilenames = getClassFilenames(class, true);
    [~, inst_abstractIDs, inst_instanceIDs] = deText(instanceFilenames);
    [inst_abstractIDs, idx] = unique(inst_abstractIDs,'stable'); % Remove duplicates
    inst_instanceIDs = inst_instanceIDs(idx);

    % Make UUID's from ID's (prepend class abbreviation)
    abs_abstractUUIDs = cell(size(abs_abstractIDs));
    for j=1:length(abs_abstractUUIDs)
        abs_abstractUUIDs{j} = genUUID(class, abs_abstractIDs{j});
    end

    inst_abstractUUIDs = cell(size(inst_instanceIDs));
    for j=1:length(inst_instanceIDs)
        inst_abstractUUIDs{j} = genUUID(class, inst_abstractIDs{j});
    end

    % Get the index of which abstract objects do not exist (but should)
    missingIdx = ~ismember(inst_abstractUUIDs, abs_abstractUUIDs);
    missingAbstracts = inst_abstractUUIDs(missingIdx);    

    % Create the missing abstract ID's, ensuring that there is a
    % corresponding abstract file.
    for j=1:length(missingAbstracts)
        instanceIDidx = ismember(inst_abstractUUIDs,missingAbstracts{j});
        instanceUUID = genUUID(class, inst_abstractIDs{instanceIDidx}, inst_instanceIDs{instanceIDidx}); % Get an instance ID for this abstract object.
        instanceStruct = loadJSON(instanceUUID);
        createNewObject(false, class, instanceStruct.Text, inst_abstractIDs{j}, '', true);
    end

end