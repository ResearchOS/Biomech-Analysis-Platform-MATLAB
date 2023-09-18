function [ordStruct]=orderedList2Struct(prList, containerList)

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

if isempty(prList)
    ordStruct = struct();
    return;
end

prettyContainerList = cell(size(containerList));
prettyContainerList(:,1) = getName(containerList(:,1));
prettyContainerList(:,2) = getName(containerList(:,2));

%% 1. Get all PR's containers.
prIdx = contains(containerList(:,1),'PR');
prContainers = unique(containerList(prIdx,2),'stable');
prettyPRContainers = unique(prettyContainerList(prIdx,2),'stable');
for i=1:length(prContainers)       
    prsInContainerIdx = ismember(containerList(:,2),prContainers{i});
    prsInContainer = containerList(prsInContainerIdx,1); % Returns things in the wrong order.Fix!
    prettyPRsInContainer = prettyContainerList(prsInContainerIdx,1);    
    % Sometimes the PR won't exist in the PR list. In that case, but it at
    % the start of the list.
    nums = NaN(length(prsInContainer),1);
    for j = 1:length(prsInContainer)
        num = find(ismember(prList(:,1),prsInContainer{j}));
        if ~isempty(num)
            nums(j) = num;
        end
    end
    nums(isnan(nums)) = -inf;
    [~,k] = sort(nums);
    nums = nums(k);
    prsInContainer = prsInContainer(k);
    prettyPRsInContainer = prettyPRsInContainer(k);
    for j=1:length(prsInContainer)
        ordStruct.(prContainers{i}).Contains.(prsInContainer{j}).Contains = {};
        ordStruct.(prContainers{i}).Contains.(prsInContainer{j}).MinNum = nums(j);
        ordStruct.(prContainers{i}).Contains.(prsInContainer{j}).PrettyName = prettyPRsInContainer{j};
    end
    nums(isinf(nums)) = []; % Exclude the minus infinity when ordering the groups.
    minNum = min(nums);
    ordStruct.(prContainers{i}).MinNum = minNum;
    ordStruct.(prContainers{i}).PrettyName = prettyPRContainers{i};
end

%% 2. Get all child PG's that are not also parent PG's
childPGIdx = contains(containerList(:,1),'PG');
childPGs = containerList(childPGIdx,1);
orphanPGs = {};
for i=1:length(childPGs)
    pgIdx = ismember(containerList(:,2),childPGs{i});
    if ~any(pgIdx)
        orphanPGs = [orphanPGs; childPGs(i)];
    end
end
prettyOrphanPGsIdx = ismember(containerList(:,1),orphanPGs);
prettyOrphanPGs = prettyContainerList(prettyOrphanPGsIdx,1);
for i=1:length(orphanPGs)
    ordStruct.(orphanPGs{i}).Contains = {};
    ordStruct.(orphanPGs{i}).MinNum = inf; % Put at the back
    ordStruct.(orphanPGs{i}).PrettyName = prettyOrphanPGs{i};
end

%% 3. Loop through all containers' UUID's, find their parent containers until the top level parent container is found
% Hard-coded the index (1,2) for the top-level parent container in
% containerList. Is this an OK assumption? Seems to be, because of the
% input to "getPRFromPG"
while ~all(ismember(fieldnames(ordStruct),containerList{1,2}))
    topLevelContainers = fieldnames(ordStruct);

    for i=1:length(topLevelContainers)
        currContainer = topLevelContainers{i};
        currContainerIdx = ismember(containerList(:,1), currContainer);        
        parentContainers = containerList(currContainerIdx,2);        
        currPrettyNames = prettyContainerList(currContainerIdx,2);
        for j = 1:length(parentContainers)
            parentContainer = parentContainers{j};
            prettyParentContainer = currPrettyNames{j};
            ordStruct.(parentContainer).Contains.(currContainer) = ordStruct.(currContainer);
            minNum = [ordStruct.(currContainer).MinNum];
            ordStruct = rmfield(ordStruct, currContainer);
            if isfield(ordStruct.(parentContainer),'MinNum')
                ordStruct.(parentContainer).MinNum = min([minNum, ordStruct.(parentContainer).MinNum]);
            else
                ordStruct.(parentContainer).MinNum = minNum;
            end
            ordStruct.(parentContainer).PrettyName = prettyParentContainer;
        end
    end

    % Reorder the struct fields according to their min nums
    currContainers = fieldnames(ordStruct.(parentContainer).Contains);
    nums = [];
    for i=1:length(currContainers)        
        if isempty(ordStruct.(parentContainer).Contains.(currContainers{i}).MinNum)
            num = inf; % Put at end
        else
            num = ordStruct.(parentContainer).Contains.(currContainers{i}).MinNum;
        end
        nums = [nums; num];
    end

    [~,k] = sort(nums);
    ordStruct.(parentContainer).Contains = orderfields(ordStruct.(parentContainer).Contains, k);

end