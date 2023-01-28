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
specifyTrials=titleSplit{end};

fullPath=getClassFilePath(specifyTrials,'SpecifyTrials');
stStruct=loadJSON(fullPath);

idxNum=find(ismember(handles.selectedLogsheetHeadersUITree.Children,selNode)==1);

stStruct.Logsheet_Headers(idxNum)=[];

stStruct.Logsheet_Logic(idxNum)=[];

stStruct.Logsheet_Value(idxNum)=[];

delete(selNode);

idxNum=idxNum-1;

if idxNum==0
    idxNum=1;
end

if ~isempty(handles.selectedLogsheetHeadersUITree.Children)
    handles.selectedLogsheetHeadersUITree.SelectedNodes=handles.selectedLogsheetHeadersUITree.Children(idxNum);
    selectedLogsheetHeadersUITreeSelectionChanged(fig);
end

saveClass('SpecifyTrials', stStruct);