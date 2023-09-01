function []=assignLogsheetHeaderButtonPushed(src,event)

%% PURPOSE: ADD A LOGSHEET HEADER TO THE CURRENT SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.logsheetHeadersUITree.SelectedNodes;

if isempty(selNode)
    return;
end

title=fig.Name;
titleSplit=strsplit(title,' ');
stUUID=titleSplit{end};

stStruct=loadJSON(stUUID);

logParams = stStruct.Logsheet_Parameters;

idx = length(logParams)+1;

%% Add header
header=selNode.Text;

uitreenode(handles.selectedLogsheetHeadersUITree,'Text',header);

logParams(idx).Headers = header;

%% Add logic
handles.logsheetLogicDropDown.Value='ignore';

logParams(idx).Logic = 'ignore';

%% Add logic value
handles.logsheetLogicValueEditField.Value='';

logParams(idx).Value = '';

%% Write the changes
stStruct.Logsheet_Parameters = logParams;
writeJSON(stStruct);

handles.selectedLogsheetHeadersUITree.SelectedNodes=handles.selectedLogsheetHeadersUITree.Children(end);