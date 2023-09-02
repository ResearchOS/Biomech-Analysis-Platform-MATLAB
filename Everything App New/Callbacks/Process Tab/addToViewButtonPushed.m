function []=addToViewButtonPushed(src,event)

%% PURPOSE: ADD A PR FROM THE CURRENT ANALYSIS/GROUP/FUNCTION LIST TO THE CURRENT VIEW

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab = handles.Process.subtabCurrent.SelectedTab;
tabTitle = tab.Title;
if isequal(tabTitle,'Function')
    tabTitle = 'Group';
end

selNode = handles.Process.([lower(tabTitle) 'UITree']).SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

if isempty(uuid)
    return;
end

type = deText(uuid);
if ~isequal(type,'PR')
    return;
end

addNodesToView(fig,uuid);

G = filterGraph(fig, Current_View);

renderGraph(fig, G);