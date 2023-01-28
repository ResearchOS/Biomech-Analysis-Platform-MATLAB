function []=logsheetLogicDropDownValueChanged(src,event)

%% PURPOSE: CHANGE THE LOGIC FOR THE CURRENT LOGSHEET HEADER.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.selectedLogsheetHeadersUITree.SelectedNodes;

if isempty(selNode)
    return;
end

title=fig.Name;
titleSplit=strsplit(title,' ');
specifyTrials=titleSplit{end};

%% Load the specify trials struct
fullPath=getClassFilePath(specifyTrials,'SpecifyTrials');
stStruct=loadJSON(fullPath);

% Index of the selected node. Nodes are in same order as in JSON.
idx=ismember(handles.selectedLogsheetHeadersUITree.Children,selNode);

logic=handles.logsheetLogicDropDown.Value;
stStruct.Logsheet_Logic{idx}=logic;

saveClass('SpecifyTrials', stStruct);