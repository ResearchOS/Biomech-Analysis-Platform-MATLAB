function [ordStruct]=orderedList2Struct(prList, containerList, ordStruct)

%% PURPOSE: CONVERT THE LIST TO STRUCT FORM TO CREATE THE ANALYSIS OR PROCESS GROUP UI TREE NODES
% 1. Get all PR's containers. Order the PR's in each container. Each
% container is a field of a struct, e.g. struct.(container).(PR)
%   - Include a "MinNum" field which is the minimum of all the PR's numbers
%   in that container.
% 2. Get all child PG's that are not also parent PG's (these are groups
% with no PR's in them), e.g. struct.(container).(PG).MinNum = inf (put at
% end)
% 3. Loop through all containers' UUID's, find their parent containers until the analysis is found
%   e.g. tmpStruct = struct.(containers);
%       - struct.(newContainer) = tmpStruct.(containersInNewContainer);
%       - struct = rmfield(struct, containers);
%       - struct.(newContainer).MinNum = min([tmpStruct.(containers).MinNum])
% 4. Finally, order the top level fields according to MinNum

% 1. Get all PR's containers.
prIdx = contains(containerList(:,1),'PR');
prContainers = unique(containerList(prIdx,2));
for i=1:length(prContainers)
    prsInContainerIdx = ismember(containerList(:,2),prContainers{i});
    prsInContainer = containerList(prsInContainerIdx,1);    
    prListIdx = ismember(prList(:,1),prsInContainer);
    nums = cell2mat(prList(prListIdx,2));
    [~,k] = sort(nums);
    prsInContainer = prsInContainer(k);
    struct.(prContainers{i}).Contains = prsInContainer;
    minNum = min(nums);
    struct.(prContainers{i}).MinNum = minNum;
end

% 2. Get all child PG's that are not also parent PG's
orphanPGIdx = contains(containerList(:,1),'PG') & ~contains(containerList(:,2),'PG'); % FIX THIS
orphanPGs = containerList(orphanPGIdx,1);
for i=1:length(orphanPGs)
    struct.(orphanPGs{i}).Contains = {};
    struct.(orphanPGs{i}).MinNum = inf; % Put at the back
end

% 3. Loop through all containers' UUID's, find their parent containers until the analysis is found
currContainers = {};
while ~all(contains(currContainers,'AN'))
    currContainers = fieldnames(struct);

    for i=1:length(currContainers)
        currContainer = currContainers{i};
        tmpStruct = struct.(currContainer);
        struct.(currCon) = [];
    end


end














if exist('ordStruct','var')~=1
    ordStruct = struct();
end

anIdx = contains(containerList(:,2),'AN');
if any(anIdx)
    containerUUID = char(unique(containerList(anIdx,2)));
else
    pgIdx = contains(containerList(:,2),'PG');
    if ~any(pgIdx)
        ordStruct = struct();
        for i=1:length(prList)
            ordStruct.(prList{i}) = struct();
        end
        return;
    end
    containerUUID = char(unique(containerList(pgIdx,2)));
end

unOrdStruct = struct();
unOrdStruct = getUnordStruct(unOrdStruct, containerUUID, prList, containerList);

end

function [unOrdStruct, prList, containerList] = getUnordStruct(unOrdStruct, containerUUID, prList, containerList)

disp('a');
containerIdx = ismember(containerList(:,2),containerUUID);
containedUUIDs = containerList(containerIdx,1);

for i=1:length(containedUUIDs)
    unOrdStruct.(containedUUIDs{i}).Contains = struct();

    % Get the minimum number of the PR's
    prIdx = ismember(prList(:,1), containedUUIDs{i});
    minNum = min(prList(prIdx,2));
    if ~isempty(minNum)
        unOrdStruct.(containedUUIDs{i}).MinNum = minNum;
    end

    % Recursively get the rest

end

end












% listTmp = containerList;
% nums = cell2mat(listTmp(:,2));
% while ~isempty(listTmp)
%     containerUUID = listTmp{1,2};
%     containerIdx = ismember(listTmp(:,2),containerUUID);
% 
%     containedIdx = ismember(containerList(:,2), containerUUID);
%     containedUUIDs = containerList(containedIdx,1); % Get the UUID of the contained objects.
% 
%     if ~any(contains(containedUUIDs,'PG'))
%         for i=1:length(containedUUIDs)
%             listTmp(containerIdx,:) = [];
%             if ~contains(containedUUIDs{i},'PG')
%                 ordStruct.(containerUUID).(containedUUIDs{i}) = struct();
%             else                
%                 listTmp
%             end
%         end
%         continue;
%     end
% 
%     % Put the 
% 
% 
% end