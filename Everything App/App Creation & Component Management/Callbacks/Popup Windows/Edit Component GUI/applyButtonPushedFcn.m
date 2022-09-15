function []=applyButtonPushedFcn(src,pgui)

%% PURPOSE: APPLY THE CHANGES MADE TO THE PROPERTIES
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
plotName=getappdata(fig,'plotName');

props=getappdata(fig,'props');
% props=Qhandles.props;

propNamesChanged=getappdata(fig,'propNamesChanged');

Plotting=getappdata(pgui,'Plotting');

%% Set each of the changed properties for the current graphics object.
h=Plotting.Plots.(plotName).(compName).(letter).Handle;

propNamesChangedTemp=propNamesChanged;
for i=1:length(propNamesChanged)
    propName=propNamesChanged{i}; % Current property name.

    try
        h.(propName)=props.(propName);
        propNamesChangedTemp=propNamesChangedTemp(~ismember(propNamesChangedTemp,propName));
    catch
        disp([propName ' Invalid as Specified:']);
        props.(propName)
    end

end

setappdata(fig,'propNamesChanged',propNamesChangedTemp);