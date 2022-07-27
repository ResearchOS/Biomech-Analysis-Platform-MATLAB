function []=createNode(fig,fcnName,prevFcnName,fcnSplitName,prevFcnSplitName,coords)

%% PURPOSE: CREATE A NODE IN THE MAP FIGURE
% Inputs:
% fig: The pgui figure object (graphics object)
% fcnName: The name of the function (char)
% prevFcnName: The name of the function to connect it to (char)
% fcnSplitName: The split name of the new function node (char)
% prevFcnSplitName: The split name of the function to connect it to (char)
% coords: The (x,y) coordinates to place the node at (double)