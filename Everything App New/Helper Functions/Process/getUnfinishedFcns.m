function [idx] = getUnfinishedFcns(G)

%% PURPOSE: GET THE LOGICAL INDEX OF THE PROCESS FUNCTIONS IN G.NODES.NAME
%  THAT HAVE NOT HAD ALL VARIABLES ADDED.

names = G.Nodes.Name;

idx = true(length(names),1);
for i=1:length(names)
    name = names{i};
    instStruct = loadJSON(name);

    [type, abstractID] = deText(name);
    abstractUUID = genUUID(type, abstractID);
    abstractStruct = loadJSON(abstractUUID);

    if isequal(type,'LG')
        continue;
    end

    % Check each getArg/setArg size
    if ~isequal(size(abstractStruct.InputVariablesNamesInCode),size(instStruct.InputVariables)) || ...
            ~isequal(size(abstractStruct.OutputVariablesNamesInCode),size(instStruct.OutputVariables))
        idx(i,1) = false;
        continue;
    end

    for j = 1:length(instStruct.InputVariables)
        if any(cellfun(@isempty, instStruct.InputVariables{j}))                
            idx(i,1) = false;
            continue;
        end
    end

    for j = 1:length(instStruct.OutputVariables)
        if any(cellfun(@isempty, instStruct.OutputVariables{j}))
            idx(i,1) = false;
            continue;
        end
    end

end

idx = ~idx; % Was returning which functions were finished, flip it to be an idx of unfinished functions.