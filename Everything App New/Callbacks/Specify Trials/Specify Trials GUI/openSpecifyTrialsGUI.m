function []=openSpecifyTrialsGUI(src,uiTree)

%% PURPOSE: OPEN A POPUP WINDOW TO EDIT THE SPECIFY TRIALS CONDITION.

pgui=ancestor(src,'figure','toplevel');
pguiHandles=getappdata(pgui,'handles');

selNode=uiTree.SelectedNodes;
if isempty(selNode)
    return;
end

%% Create all of the components
uuid = selNode.NodeData.UUID;
fig=uifigure('Name',[selNode.Text ' ' uuid],'AutoResizeChildren','off',...
    'Visible','on','SizeChangedFcn',@(specifyTrialsSizeChanged,event) specifyTrialsResize(specifyTrialsSizeChanged));

handles=initializeComponents_SpecifyTrials(fig);
setappdata(fig,'handles',handles);

specifyTrialsResize(fig);

setappdata(fig,'pguiHandles',pguiHandles);
setappdata(fig,'pgui',pgui);

stStruct=loadJSON(uuid);

%% Initialize the complete list of headers
% 1. Get the current logsheet name.
selLogsheet = getCurrent('Current_Logsheet');

% 2. Load the logsheet struct
logsheetStruct=loadJSON(selLogsheet);

% 3. Get the header names that have been properly filled in
allHeaders=logsheetStruct.Headers;
allLevels=logsheetStruct.Level;
allTypes=logsheetStruct.Type;
okIdx=~cellfun(@isempty,allLevels) & ~cellfun(@isempty,allTypes);
disp(allHeaders(~okIdx));
allHeaders=allHeaders(okIdx);

for i=1:length(allHeaders)
    uitreenode(handles.logsheetHeadersUITree,'Text',allHeaders{i});    
end

if ~isempty(handles.logsheetHeadersUITree.Children)
    handles.logsheetHeadersUITree.SelectedNodes=handles.logsheetHeadersUITree.Children(1);
end

%% Initialize the selected headers
selHeaders={stStruct.Logsheet_Parameters.Headers};

for i=1:length(selHeaders)
    uitreenode(handles.selectedLogsheetHeadersUITree,'Text',selHeaders{i});
end

if isempty(handles.selectedLogsheetHeadersUITree.Children)
    return;
end

handles.selectedLogsheetHeadersUITree.SelectedNodes=handles.selectedLogsheetHeadersUITree.Children(1);
selectedLogsheetHeadersUITreeSelectionChanged(fig);