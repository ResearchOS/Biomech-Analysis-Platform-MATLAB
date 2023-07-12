function []=addAnalysisButtonPushed(src)

%% PURPOSE: CREATE A NEW ANALYSIS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

anName=promptName('Enter Analysis Name');

if isempty(anName)
    return;
end

anStruct = createNewObject(false, 'Analysis', anName, '', '', true);

addNewNode(handles.Process.allAnalysesUITree, anStruct.UUID, anStruct.Text);

figure(fig);