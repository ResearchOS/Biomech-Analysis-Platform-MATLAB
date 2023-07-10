function []=addProcessButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESS FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

processName=promptName('Enter Processing Function Name');

if isempty(processName)
    return;
end

createNewObject(false, 'Process', processName, '', '', true);

searchTerm=getSearchTerm(handles.Process.processSearchField);

fillUITree(fig,'Process',handles.Process.allProcessUITree,...
    searchTerm,handles.Process.sortProcessDropDown);

figure(fig);