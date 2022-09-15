function []=applyButtonPushedFcn(src,pgui)

%% PURPOSE: APPLY THE CHANGES MADE TO THE PROPERTIES
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
plotName=getappdata(fig,'plotName');

props=Qhandles.props;

propNamesChanged=Qhandles.propNamesChanged;

Plotting=getappdata(pgui,'Plotting');

%% Set each of the changed properties for the current graphics object.
h=Plotting.Plots.(plotName).(compName).(letter).Handle;

for i=1:length(propNamesChanged)
    propName=propNamesChanged{i}; % Current property name.

    h.(propName)=props.(propName);

end