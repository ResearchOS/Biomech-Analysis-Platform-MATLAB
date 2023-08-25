function []=checkAllButtonPushed(src,event)

%% PURPOSE: CHECK ALL VARIABLES WITH PROPER DATA

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

Current_Logsheet = getCurrent('Current_Logsheet');
struct=loadJSON(Current_Logsheet);

levels={struct.LogsheetVar_Params.Level};
type={struct.LogsheetVar_Params.Type};

emptyIdxLevel=cellfun(@isempty,levels);
emptyIdxType=cellfun(@isempty,type);

emptyIdx=emptyIdxLevel | emptyIdxType;

if any(~emptyIdx)
    handles.Import.headersUITree.CheckedNodes=handles.Import.headersUITree.Children(~emptyIdx);
end