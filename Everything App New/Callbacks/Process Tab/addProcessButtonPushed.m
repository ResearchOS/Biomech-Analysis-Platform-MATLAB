function []=addProcessButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESS FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

processName=promptName('Enter Processing Function Name');

if isempty(processName)
    return;
end

createProcessStruct(fig,processName);

searchTerm=getSearchTerm(handles.Process.processSearchField);

fillUITree(fig,'Process',handles.Process.allProcessUITree,...
    searchTerm,handles.Process.sortProcessDropDown);