function []=makeMultVarStatsNodes(fig,cats,allVars,assignedVars)

%% PURPOSE: CREATE THE NODES FOR THE CURRENT REPETITION MULTI VARIABLE
fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');