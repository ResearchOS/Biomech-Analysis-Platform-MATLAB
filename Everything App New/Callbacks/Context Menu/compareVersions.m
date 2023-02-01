function []=compareVersions(src,event)

%% PURPOSE: COMPARE MULTIPLE VERSIONS OF THE SAME COMMON OBJECT.

disp('Not done yet!');
return;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;