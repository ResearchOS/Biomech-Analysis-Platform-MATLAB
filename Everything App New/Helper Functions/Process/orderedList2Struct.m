function [ordStruct]=orderedList2Struct(prList, containerList, ordStruct)

%% PURPOSE: CONVERT THE LIST TO STRUCT FORM TO CREATE THE ANALYSIS OR PROCESS GROUP UI TREE NODES

if exist('ordStruct','var')~=1
    ordStruct = struct();
end

anIdx = contains(containerList(:,2),'AN');
if any(anIdx)
    anUUID = char(unique(containerList(anIdx,2)));
end

listTmp = containerList;
nums = cell2mat(listTmp(:,2));
while ~isempty(listTmp)
    containerUUID = listTmp{1,2};
    containerIdx = ismember(listTmp(:,2),containerUUID);

    containedIdx = ismember(containerList(:,2), containerUUID);
    containedUUIDs = containerList(containedIdx,1); % Get the UUID of the contained objects.

    if ~any(contains(containedUUIDs,'PG'))
        for i=1:length(containedUUIDs)
            listTmp(containerIdx,:) = [];
            if ~contains(containedUUIDs{i},'PG')
                ordStruct.(containerUUID).(containedUUIDs{i}) = struct();
            else                
                listTmp
            end
        end
        continue;
    end

    % Put the 


end