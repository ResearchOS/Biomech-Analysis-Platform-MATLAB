function []=selectedLogsheetHeadersUITreeSelectionChanged(src,event)

%% PURPOSE: CHANGE THE LOGIC & VALUE BEING DISPLAYED.

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

logic=stStruct.Logsheet_Logic{idx};
handles.logsheetLogicDropDown.Value=logic;

value=stStruct.Logsheet_Value{idx};
handles.logsheetLogicValueEditField.Value=value;