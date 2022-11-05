function []=assignVarsDeleteFcn(src)

%% PURPOSE: WHEN THE WINDOW CLOSES, ASSIGN THE VARIABLES BACK TO THE PLOTTING VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

pgui=findall(0,'Name','pgui');

Plotting=getappdata(pgui,'Plotting');

plotName=getappdata(fig,'plotName');
compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');

Plotting.Plots.(plotName).(compName).(letter).Variables=comp;

setappdata(pgui,'Plotting',Plotting);