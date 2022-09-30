function []=makeVarNodes(fig,sortIdx,VariableNamesList)

handles=getappdata(fig,'handles');
delete(handles.Process.varsListbox.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)
% for i=1:length(VariableNamesList.GUINames)
    varNode=uitreenode(handles.Process.varsListbox,'Text',VariableNamesList.GUINames{sortIdx(i)});
    varNode.ContextMenu=handles.Process.collapseAllContextMenu;
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
        a.ContextMenu=handles.Process.collapseAllContextMenu;
        if i==1 && j==1
            handles.Process.varsListbox.SelectedNodes=a;
        end
    end
end

varsListboxSelectionChanged(fig);