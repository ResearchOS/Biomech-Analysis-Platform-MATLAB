function []=outOfDateCheckboxValueChanged(src,event)

%% PURPOSE: SET THE OUT OF DATE VALUE FOR THE CURRENTLY SELECTED FUNCTION IN THE GROUP UI TREE
fig = ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles'); 

selNode = handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

outOfDateBool = handles.Process.outOfDateCheckbox.Value;

uuid = selNode.NodeData.UUID;

struct = loadJSON(uuid);

struct.OutOfDate = outOfDateBool;

writeJSON(getJSONPath(struct), struct);

%% UPDATE EACH OF THE OUTPUT VARIABLES TO ALSO BE OUT OF DATE, RECURSIVELY (ALL DEPENDENCIES)
% if ~outOfDateBool
%     depPR = {uuid};
% else
depPR = orderDeps(getappdata(fig,'digraph'), 'partial', uuid);
% end
for i=1:length(depPR)
    struct = loadJSON(depPR{i});    

    % If setting out of date false, only works if all of the input variables are up to date.
    elig = true; % Initialize that the function is eligible to be up to date if and only if all of its inputs are up to date
    if ~outOfDateBool        
        inVars = getVarNamesArray(struct, 'InputVariables');
        for j=1:length(inVars)
            if isempty(inVars{j})
                continue;
            end
            varStruct = loadJSON(inVars{j});
            [type, abstractID] = deText(varStruct.UUID);
            absVar = genUUID(type, abstractID);
            absStruct = loadJSON(absVar);
            if varStruct.OutOfDate && ~absStruct.IsHardCoded
                elig = false;
                break;
            end
        end
    end

    if elig
        %% Updates all of the output variables downstream. May or may not want this, depending.
%         outVars = getVarNamesArray(struct,'OutputVariables');
%         for j=1:length(outVars)
%             if isempty(outVars{j})
%                 continue;
%             end
%             varStruct = loadJSON(outVars{j});
%             varStruct.OutOfDate = outOfDateBool;
%             writeJSON(getJSONPath(varStruct), varStruct);
%         end
        % Update the process function.
        struct.OutOfDate = outOfDateBool;
        writeJSON(getJSONPath(struct), struct);
    end    
end

toggleDigraphCheckboxValueChanged(fig);