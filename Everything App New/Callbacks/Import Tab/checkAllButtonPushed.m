function []=checkAllButtonPushed(src,event)

%% PURPOSE: CHECK ALL VARIABLES WITH PROPER DATA

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath(selNode);
struct=loadJSON(fullPath);

levels=struct.Level;
type=struct.Type;

emptyIdxLevel=cellfun(@isempty,levels);
emptyIdxType=cellfun(@isempty,type);

emptyIdx=emptyIdxLevel | emptyIdxType;

if any(~emptyIdx)
    handles.Import.headersUITree.CheckedNodes=handles.Import.headersUITree.Children(~emptyIdx);
end