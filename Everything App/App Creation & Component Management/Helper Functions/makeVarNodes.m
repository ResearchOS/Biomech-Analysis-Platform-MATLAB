function []=makeVarNodes(fig,sortIdx,VariableNamesList)

handles=getappdata(fig,'handles');

for i=1:length(VariableNamesList.GUINames)
    varNode=uitreenode(handles.Process.varsListbox,'Text',VariableNamesList.GUINames{sortIdx(i)});
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
        if i==1 && j==1
            handles.Process.varsListbox.SelectedNodes=a;
        end
    end
end

varsListboxSelectionChanged(fig);