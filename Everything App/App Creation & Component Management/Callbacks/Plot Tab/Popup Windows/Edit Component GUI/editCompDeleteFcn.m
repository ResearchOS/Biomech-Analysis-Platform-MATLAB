function []=editCompDeleteFcn(src,pguiFig)

%% PURPOSE: STORE THE CHANGES TO THE COMPONENT BACK TO THE PLOTTING SETTINGS VARIABLE
fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

propsChangedList=getappdata(fig,'propsChangedList');

Plotting=getappdata(pguiFig,'Plotting');

compName=getappdata(fig,'compName');
plotName=getappdata(fig,'plotName');
letter=getappdata(fig,'letter');
allProps=getappdata(fig,'allProps');

Plotting.Plots.(plotName).(compName).(letter).ChangedProperties=propsChangedList;
Plotting.Plots.(plotName).(compName).(letter).Properties=allProps;

setappdata(pguiFig,'Plotting',Plotting);

evalin('base','clear currentPropertyValue;');