function []=varsListboxSelectionChanged(src,event)

%% PURPOSE: UPDATE THE METADATA FOR THE SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.varsListbox.SelectedNodes;
if isempty(selNode)
    return;
end
text=selNode.Text;
if ~contains(text,'(') 
    expand(handles.Process.varsListbox.SelectedNodes);
    handles.Process.varsListbox.SelectedNodes=selNode.Children(1);
    varsListboxSelectionChanged(fig);
    return; % This is a variable name, not a split name & code
end

spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
% splitCode=text(spaceIdx+2:end-1);
guiVarName=selNode.Parent.Text; % The name of the current variable

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'VariableNamesList');
VariableNamesList=getappdata(fig,'VariableNamesList');

varGUINameRowIdx=ismember(VariableNamesList.GUINames,guiVarName);

splitsRowIdx=false(size(varGUINameRowIdx));
for i=1:length(VariableNamesList.SplitNames)
    if ismember(splitName,getUniqueMembers(VariableNamesList.SplitNames))
        splitsRowIdx(i)=true;
    end
end

rowIdx=varGUINameRowIdx & splitsRowIdx;
assert(sum(rowIdx)==1);

handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{rowIdx};