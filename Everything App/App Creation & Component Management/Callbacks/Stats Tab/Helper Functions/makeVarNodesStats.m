function []=makeVarNodesStats(fig,sortIdx,VariableNamesList)

handles=getappdata(fig,'handles');
delete(handles.Stats.varsUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)
    varNode=uitreenode(handles.Stats.varsUITree,'Text',VariableNamesList.GUINames{sortIdx(i)});
%     varNode.ContextMenu=handles.Stats.collapseAllContextMenu;
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
%         a.ContextMenu=handles.Stats.collapseAllContextMenu;
        if i==1 && j==1
            handles.Stats.varsUITree.SelectedNodes=a;
        end
    end
end

% varsListboxSelectionChanged(fig);