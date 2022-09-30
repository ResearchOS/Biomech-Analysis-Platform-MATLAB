function []=dcmButtonPushed(src,event)

%% PURPOSE: ENABLE OR DISABLE DATA CURSOR MODE TO EXPLORE THE PLOTS.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

% val=handles.Plot.dcmButton.Value;

% axHandle=Plotting.Plots.(plotName).Axes.A.Handle;

dcm=datacursormode(fig);
if isequal(char(dcm.Enable),'on')
    dcm.Enable='off';
else
    dcm.Enable='on';
end
% dcm.Enable
% dcm.DisplayStyle='window';