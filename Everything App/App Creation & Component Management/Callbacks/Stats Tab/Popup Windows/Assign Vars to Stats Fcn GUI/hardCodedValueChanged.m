function []=hardCodedValueChanged(src)

%% PURPOSE: CHANGE THE HARD-CODED VALUE OF THE COMPONENT'S VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

plotName=getappdata(fig,'plotName');
compName=getappdata(fig,'compName');
letter=getappdata(fig,'letter');
structComp=getappdata(fig,'structComp');

val=handles.hardCodedTextArea.Value{1};

structComp.HardCodedValue=eval(val);

setappdata(fig,'structComp',structComp);