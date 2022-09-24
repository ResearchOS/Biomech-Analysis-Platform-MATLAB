function []=applyButtonPushedFcn(src,pgui)

%% PURPOSE: APPLY THE CHANGES MADE TO THE PROPERTIES
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
plotName=getappdata(fig,'plotName');
h=getappdata(fig,'objH');
currProp=getappdata(fig,'currProp');

val=evalin('base','currentPropertyValue;');

if ~isequal(compName,'Axes')
    h=h.Children;
end

for i=1:length(h)
    if ~isempty(properties(h(i)))
        if isequal(h(i).(currProp),val)
%             h(i).(currProp)=val;
            continue;
        end
        % Add this property to the list of manually edited properties. Every time the graphics objects are updated, they should use these property
        % values to keep the graphics objects the same.
        h(i).(currProp)=val;


    end
end

evalin('base','closevar(''currentPropertyValue'');');

