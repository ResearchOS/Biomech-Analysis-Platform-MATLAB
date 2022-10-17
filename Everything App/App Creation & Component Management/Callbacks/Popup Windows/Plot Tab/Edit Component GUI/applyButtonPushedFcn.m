function []=applyButtonPushedFcn(src,pgui)

%% PURPOSE: APPLY THE CHANGES MADE TO THE PROPERTIES
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
plotName=getappdata(fig,'plotName');
h=getappdata(fig,'objH');
currProp=getappdata(fig,'currProp');
propsChangedList=getappdata(fig,'propsChangedList');

val=evalin('base','currentPropertyValue;');

if ~isequal(compName,'Axes')
    h=h.Children; % If the current component is not an axes, then it is actually a group. This converts it to be the components themselves.
end

% propsChangedList=cell(size(h)); % List of properties that have been changed for each component in the current group.

for i=1:length(h)
    if ~isempty(properties(h(i)))
        % Update the property
        h(i).(currProp)=val;

        % Add this property to the list of manually edited properties. Every time the graphics objects are updated, they should use these property
        % values to keep the graphics objects the same.
        % Later on I should institute a check to see whether this has been changed back to the default, for efficiency when plotting.
        propsChangedList{i}=unique([propsChangedList{i}; {currProp}]); % Add this property to the list of properties that have been modified.

    end
end

setappdata(fig,'propsChangedList',propsChangedList);
evalin('base','closevar(''currentPropertyValue'');');

