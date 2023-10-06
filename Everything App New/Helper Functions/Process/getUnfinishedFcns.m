function [idx] = getUnfinishedFcns(G)

%% PURPOSE: GET THE LOGICAL INDEX OF THE PROCESS FUNCTIONS IN G.NODES.NAME
%  THAT HAVE NOT HAD ALL VARIABLES ADDED.

names = G.Nodes.Name;
[type, abstractID] = deText(names);
abstractUUIDs = cell(size(names));
for i=1:length(names)
    abstractUUIDs{i} = genUUID(type{i}, abstractID{i});
end

sqlquery = ['SELECT PR_ID, NameInCode FROM VR_PR;'];
tIn = fetchQuery(sqlquery);
prIn = tIn.PR_ID;
prInName = tIn.NameInCode;

sqlquery = ['SELECT PR_ID, NameInCode FROM PR_VR;'];
tOut = fetchQuery(sqlquery);
prOut = tOut.PR_ID;
prOutName = tOut.NameInCode;

% pr = [prIn; prOut];

% idx = ismember(names,pr);

sqlquery = ['SELECT UUID, InputVariablesNamesInCode, OutputVariablesNamesInCode FROM Process_Abstract'];
absPR = fetchQuery(sqlquery);

% [~,ia,ib] = intersect(abstractUUIDs,absPR.UUID,'stable');
absUUIDs = absPR.UUID;
inVars = absPR.InputVariablesNamesInCode;
outVars = absPR.OutputVariablesNamesInCode;

idx = false(length(names),1);
for i=1:length(names)
    name = names{i};
    [type, abstractID] = deText(name);
    if isequal(type,'LG')
        continue;
    end
    abstractName = genUUID(type, abstractID);
    absIdx = ismember(absUUIDs, abstractName);

    % Idx of all names in code for this instance object.
    inIdx = ismember(prIn, name);
    outIdx = ismember(prOut, name);    

    % The names in code that are in the abstract object.
    inVarsCurr = inVars{absIdx};
    outVarsCurr = outVars{absIdx};

    for j=1:length(inVarsCurr)
        if ~all(ismember(inVarsCurr{j}(2:end),prInName(inIdx)))
            idx(i,1) = true;
            break;
        end
    end

    for j=1:length(outVarsCurr)
        if ~all(ismember(outVarsCurr{j}(2:end),prOutName(outIdx)))
            idx(i,1) = true;
            break;
        end
    end

end

% idx = ~idx; % Was returning which functions were finished, flip it to be an idx of unfinished functions.