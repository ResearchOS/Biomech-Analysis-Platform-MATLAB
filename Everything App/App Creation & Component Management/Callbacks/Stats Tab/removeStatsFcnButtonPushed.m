function []=removeStatsFcnButtonPushed(src,event)

%% PURPOSE: REMOVE A STATS FUNCTION FROM THE LIST. DOES NOT DELETE THE FUNCTION'S FILE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.fcnsUITree.SelectedNodes)
    return;
end

fcnName=handles.Stats.fcnsUITree.SelectedNodes.Text;

Stats.Functions=Stats.Functions(~ismember(Stats.Functions,fcnName));

makeStatsFcnNodes(fig,1:length(Stats.Functions),Stats.Functions);

setappdata(fig,'Stats',Stats);