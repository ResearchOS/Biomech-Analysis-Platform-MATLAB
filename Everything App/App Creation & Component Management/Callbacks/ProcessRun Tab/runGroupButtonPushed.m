function []=runGroupButtonPushed(src,event)

%% PURPOSE: START THE RUN CODE ON THE CURRENT PROCESSING GROUP AFTER THE RUN BUTTON IS PRESSED

fig=ancestor(src,'figure','toplevel');

hRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupName=hRunDropDown.Value;

if isequal(groupName,'Create Function Group')
    beep;
    warning('Create function group first!');
    return;
end

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Need to enter the code path!');
    return;
end

tic;
runProcessFunctions(groupName,fig);
toc;