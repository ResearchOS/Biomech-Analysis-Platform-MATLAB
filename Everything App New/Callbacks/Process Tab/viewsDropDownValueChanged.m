function []=viewsDropDownValueChanged(src,event)

%% PURPOSE: SWITCH TO A NEW VIEW IN THE CURRENT ANALYSIS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

items = handles.Process.viewsDropDown.ItemsData;
value = handles.Process.viewsDropDown.Value;

itemsIdx = ismember(items,value);
uuid = handles.Process.viewsDropDown.ItemsData{itemsIdx};
setCurrent(uuid, 'Current_View');

appFolder = getappdata(fig,'appFolder');
tmpPath = [appFolder filesep 'Tmp JSON' filesep uuid '.json'];

% Check if the edit view button should be 1 or 0.
value = 0;
if isfile(tmpPath)
    value = 1;
end
handles.Process.editViewButton.Value = value;

viewAxes = handles.Process.toggleDigraphCheckbox.Value;

if viewAxes==1
    G = filterGraph(fig, uuid); % Filter the 'ALL' graph with the current view.

    renderGraph(fig, G); % Render the filtered graph.
end