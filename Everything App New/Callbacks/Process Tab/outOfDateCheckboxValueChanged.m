function []=outOfDateCheckboxValueChanged(src,event)

%% PURPOSE: SET THE OUT OF DATE VALUE FOR THE CURRENTLY SELECTED FUNCTION IN THE GROUP UI TREE
fig = ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles'); 

selNode = handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

value = handles.Process.outOfDateCheckbox.Value;

uuid = selNode.NodeData.UUID;

struct = loadJSON(uuid);

struct.OutOfDate = value;

writeJSON(getJSONPath(struct), struct);

%% UPDATE EACH OF THE OUTPUT VARIABLES TO ALSO BE OUT OF DATE, RECURSIVELY (ALL DEPENDENCIES)
if ~value
    depPR = {uuid};
else
    depPR = orderDeps(getappdata(fig,'digraph'), 'partial', uuid);
end
for i=1:length(depPR)
    struct = loadJSON(depPR{i});
    outVars = getVarNamesArray(struct,'OutputVariables');
    writeJSON(getJSONPath(struct), struct);
    for j=1:length(outVars)
        varStruct = loadJSON(outVars{j});
        varStruct.OutOfDate = value;
        writeJSON(getJSONPath(varStruct), varStruct);
    end
end

toggleDigraphCheckboxValueChanged(fig);