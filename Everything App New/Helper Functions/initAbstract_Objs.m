function []=initAbstract_Objs()

%% PURPOSE: ENSURE THAT EVERY OBJECT INSTANCE HAS A CORRESPONDING ABSTRACT OBJECT
classNames = className2Abbrev('list');

for i=1:length(classNames)

    class = classNames{i};
    abstractFilenames = getClassFilenames(class, false);
    instanceFilenames = getClassFilenames(class, true);

    % Abstract
    [abbrev, abs_abstractIDs] = deText(abstractFilenames);
    for j=length(abs_abstractIDs):-1:1
        abstractFiles{j} = genUUID(class, abs_abstractIDs{j});
    end

    % Instances
    [abbrev, inst_abstractIDs, inst_instanceIDs] = deText(instanceFilenames);
    [inst_abstractIDs, idx] = unique(inst_abstractIDs,'stable'); % Remove duplicates
    inst_instanceIDs = inst_instanceIDs(idx);

    % Get the index of which abstract objects do not exist (but should)
    missingIdx = ismember(abstractID, abstractFiles);
    missingAbstracts = abstractFiles(missingIdx);

    % Create the missing abstract ID's, ensuring that there is a
    % corresponding abstract file.
    for j=1:length(missingAbstracts)
        abstractID = missingAbstracts{j};


        instanceID = genUUID(class, inst_abstractIDs{j}, inst_instanceIDs{j});
        instance = loadJSON(instanceID);
        createNewObject(false, class, instance.Text, abstractID, '', true);

    end

end