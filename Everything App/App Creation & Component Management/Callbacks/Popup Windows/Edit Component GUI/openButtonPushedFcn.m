function []=openButtonPushedFcn(src,event)

%% PURPOSE: OPEN THE CURRENTLY SELECTED PROPERTY IN THE EDIT COMPONENT PROPERTIES WINDOW
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
plotName=getappdata(fig,'plotName');
h=getappdata(fig,'objH');

currProp=handles.propsList.Value;

if ~isequal(compName,'Axes')
    a=h.Children(1).(currProp);
else
    a=h.(currProp);
end

setappdata(fig,'currProp',currProp);

propClass=class(a);

charClasses={'matlab.lang.OnOffSwitchState'};

if ismember(propClass,charClasses)
    a=char(a);
end

assignin('base','currentPropertyValue',a);
evalin('base','openvar(''currentPropertyValue'');');