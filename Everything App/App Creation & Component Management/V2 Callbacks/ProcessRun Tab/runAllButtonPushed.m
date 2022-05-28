function []=runAllButtonPushed(src,event)

%% PURPOSE: RUN ALL PROCESSING FUNCTION GROUPS AT ONCE WHEN THE RUN ALL BUTTON IS PUSHED

fig=ancestor(src,'figure','toplevel');

hRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupNames=hRunDropDown.Items;

if isequal(groupNames,{'Create Function Group'})
    beep;
    warning('Create function group first!');
    return;
end

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Need to enter the code path!');
    return;
end

for i=1:length(groupNames)
    groupName=groupNames{i};
    runProcessFunctions(groupName,fig);
end