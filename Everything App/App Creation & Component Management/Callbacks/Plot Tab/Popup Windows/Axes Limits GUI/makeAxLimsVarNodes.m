function []=makeAxLimsVarNodes(fig,sortIdx,VariableNamesList)

%% PURPOSE: CREATE THE LIST OF ALL GUI VARIABLES
handles=getappdata(fig,'handles');
delete(handles.varsUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)
    varNode=uitreenode(handles.varsUITree,'Text',VariableNamesList.GUINames{sortIdx(i)});
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
        if i==1 && j==1
            expand(varNode);
            handles.varsUITree.SelectedNodes=a;
        end
    end
end