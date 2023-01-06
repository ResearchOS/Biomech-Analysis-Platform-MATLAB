function []=addComponentButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PLOT COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

componentName=promptName('Enter Plot Component Name');

if isempty(componentName)
    return;
end

createComponentStruct(fig,componentName);

searchTerm=getSearchTerm(handles.Plot.componentSearchField);

fillUITree(fig,'Component',handles.Plot.allComponentsUITree,...
    searchTerm,handles.Plot.sortComponentsDropDown);