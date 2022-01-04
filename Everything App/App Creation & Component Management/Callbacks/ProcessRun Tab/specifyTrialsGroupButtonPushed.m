function []=specifyTrialsGroupButtonPushed(src,event)

%% PURPOSE: OPEN THE GROUP LEVEL SPECIFY TRIALS, OR CREATE IT FROM TEMPLATE IF IT DOES NOT YET EXIST.

fig=ancestor(src,'figure','toplevel');

hRunGroupDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupName=hRunGroupDropDown.Value;

if isequal(groupName,'Create Function Group')
    beep;
    warning(['Create a function group first!']);
    return;
end

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Need to enter the code path!');
return;
end

groupFcnName=groupName(isstrprop(groupName,'alpha') | isstrprop(groupName,'digit'));

specifyTrialsName=[groupFcnName '_Process_SpecifyTrials.m']; % The group level specify trials function name.

if ismac==1 
    slash='/';
elseif ispc==1
    slash='\';
end

specifyTrialsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Group' slash specifyTrialsName];

if exist(specifyTrialsPath,'file')==2
    edit(specifyTrialsPath);
    return;
end

if exist([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Group'],'dir')~=7
    mkdir([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Group']);
end

% If the file does not exist yet, create it from the template.
templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'specifyTrials_Template.m'];

firstLine=['function [inclStruct]=' specifyTrialsName(1:end-2) '()'];
createFileFromTemplate(templatePath,specifyTrialsPath,firstLine)