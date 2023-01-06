function []=addPlotButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PLOT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

plotName=promptName('Enter Plot Name');

if isempty(plotName)
    return;
end

createPlotStruct(fig,plotName);

searchTerm=getSearchTerm(handles.Plot.plotSearchField);

fillUITree(fig,'Plot',handles.Plot.allPlotsUITree,...
    searchTerm,handles.Plot.sortPlotsDropDown);