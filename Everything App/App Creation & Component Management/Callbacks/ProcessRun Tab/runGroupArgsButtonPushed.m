function []=runGroupArgsButtonPushed(src)

%% PURPOSE: CREATE FROM TEMPLATE OR OPEN THE ARGUMENTS FUNCTION FOR THIS PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

runGroupDropDown=handles.ProcessRun.runGroupNameDropDown;
groupName=[runGroupDropDown.Value '_Args'];

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

argsFolder=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Group'];
if exist(argsFolder,'dir')~=7
    mkdir(argsFolder);
end

argsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Group' slash groupName '.m'];

if exist(argsPath,'file')==2
    edit(argsPath);
else % If the arguments file does not exist, create it from the template.
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'Process_argsTemplate.m'];
%     firstLine=['function [argsVars,argsPaths]=' fcnName '(projectStruct,subName,trialName,repNum)'];
    createFileFromTemplate(templatePath,argsPath,groupName)
end