function []=makeCurrCompNodes(fig,currPlot,compName,letter)

%% PURPOSE: CREATE THE NODES FOR THE CURRENT COMPONENTS IN THIS PLOT.
handles=getappdata(fig,'handles');

delete(handles.Plot.currCompUITree.Children);

compNames=fieldnames(currPlot);

if isempty(compNames)
    return;
end

for i=1:length(compNames)

    letters=fieldnames(currPlot.(compNames{i}));

    if isequal(compNames{i},'Axes')
        parentObj=handles.Plot.currCompUITree;
        compNode=uitreenode(parentObj,'Text',compNames{i});
    end

    for j=1:length(letters)        

        if ~isequal(compNames{i},'Axes')
            % Get the axes letter that is the parent of this object.
            parentAx=currPlot.(compNames{i}).(letters{j}).Parent;
            spaceIdx=strfind(parentAx,' ');
            axLetter=parentAx(spaceIdx+1:end);
            parentObj=findall(handles.Plot.currCompUITree,'Text','Axes');
            parentObj=findall(parentObj,'Text',axLetter);
            if isempty(parentObj)
                return; % All components have been removed.
            end
            compObj=findall(parentObj,'Text',compNames{i});
            if isempty(compObj)
                compNode=uitreenode(parentObj,'Text',compNames{i});
            end
        end

        letNode=uitreenode(compNode,'Text',letters{j});

    end

end

if nargin<=2
    return;
end

selNodeParent=findobj(handles.Plot.currCompUITree,'Text',compName);
if isempty(selNodeParent)
    return;
end
expand(selNodeParent(1));
selNode=findobj(selNodeParent,'Text',letter);
if ~isempty(selNode)
    handles.Plot.currCompUITree.SelectedNodes=selNode;
else
    handles.Plot.currCompUITree.SelectedNodes=selNodeParent.Children(1);
end