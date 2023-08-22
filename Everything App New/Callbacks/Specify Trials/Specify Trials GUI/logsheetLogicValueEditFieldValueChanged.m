function []=logsheetLogicValueEditFieldValueChanged(src,event)

%% PURPOSE: CHANGE THE VALUE FOR THE SELECTED LOGSHEET HEADER

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.selectedLogsheetHeadersUITree.SelectedNodes;

if isempty(selNode)
    return;
end

title=fig.Name;
titleSplit=strsplit(title,' ');
stUUID=titleSplit{end};

%% Load the specify trials struct
stStruct=loadJSON(stUUID);

% Index of the selected node. Nodes are in same order as in JSON.
idx=ismember(handles.selectedLogsheetHeadersUITree.Children,selNode);

logicValue=handles.logsheetLogicValueEditField.Value;
stStruct.Logsheet_Value{idx}=logicValue;

writeJSON(getJSONPath(stStruct), stStruct);