function []=unassignLogsheetHeaderButtonPushed(src,event)

%% PURPOSE: REMOVE A SELECTED LOGSHEET HEADER FROM THE SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.selectedLogsheetHeadersUITree.SelectedNodes;

if isempty(selNode)
    return;
end

title=fig.Name;
titleSplit=strsplit(title,' ');
stUUID=titleSplit{end};

stStruct=loadJSON(stUUID);

idxNum=find(ismember(handles.selectedLogsheetHeadersUITree.Children,selNode)==1);

stStruct.Logsheet_Parameters(idxNum) = [];

delete(selNode);

idxNum=idxNum-1;

if idxNum==0
    idxNum=1;
end

if ~isempty(handles.selectedLogsheetHeadersUITree.Children)
    handles.selectedLogsheetHeadersUITree.SelectedNodes=handles.selectedLogsheetHeadersUITree.Children(idxNum);
    selectedLogsheetHeadersUITreeSelectionChanged(fig);
end

writeJSON(stStruct);