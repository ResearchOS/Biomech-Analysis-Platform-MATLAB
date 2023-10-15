function [uuidL, uuidR] = getLRObjs(uuid1, uuid2)

%% PURPOSE: GIVEN TWO UUID'S, ORDER THEM IN THE CORRECT ORDER TO BE PUT IN THE EDGE TABLE (PRIMARILY VR/PR COMBO'S)

type1 = deText(uuid1);
type2 = deText(uuid2);

% If not VR & PR being assigned together, then the order doesn't matter
% because linkObjs takes care of it.
if ~all(ismember({type1,type2},{'VR','PR'}))
    uuidL = uuid1;
    uuidR = uuid2;
    return;
end

%% Get whether it's an input or output variable.
selNode = handles.Process.currentFunctionUITree.SelectedNodes;

[~, list] = getUITreeFromNode(selNode);
if length(list)>2
    selNode = list(2);
end

%% Put the objects in the proper order.
if contains(selNode.Text,'setArg')
    if isequal(type1,'VR')
        uuidL = uuid2;
        uuidR = uuid1;        
    elseif isequal(type1,'PR')
        uuidL = uuid1;
        uuidR = uuid2;        
    end
elseif contains(selNode.Text, 'getArg')
    if isequal(type1,'VR')
        uuidL = uuid1;
        uuidR = uuid2;
    elseif isequal(type1,'PR')
        uuidL = uuid2;
        uuidR = uuid1;
    end
end