function [struct] = createAndShowObject(parent, instanceBool, type, name, abstractID, instanceID, saveObjBool, args)

%% PURPOSE: CREATE A NEW OBJECT AND DISPLAY THE NODE IN THE APPROPRIATE UI TREE.

if exist('args','var')~=1
    args = '';
end

% 1. Create the new abstract object.
struct = createNewObject(instanceBool, type, name, abstractID, instanceID, saveObjBool, args);
if isempty(struct)
    return;
end

% 2. Add it to the UI tree & select it.
addNewNode(parent, struct.UUID, struct.Name);
uiTree = getUITreeFromNode(parent);
selectNode(uiTree, struct.UUID);