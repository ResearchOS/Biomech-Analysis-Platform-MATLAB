function []=plotMapFigure(fig,FunctionNamesList)

%% PURPOSE: WHEN OPENING THE PGUI, PLOT THE PROCESSING MAP FIGURE
% Inputs:
% fig: The pgui figure object (graphics object)
% FunctionNamesList: The saved list of functions being used and their
% connections, metadata, and attributes

fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');

mapFig=handles.Process.mapFigure;

for i=1:length(FunctionNamesList.FunctionNames)

    scatter(mapFig,FunctionNamesList.Coordinates{i}(1),FunctionNamesList.Coordinates{i}(2))
    createNode

end