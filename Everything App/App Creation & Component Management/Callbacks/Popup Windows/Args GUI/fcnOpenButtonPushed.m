function []=fcnOpenButtonPushed(src,event)

%% PURPOSE: OPEN THE ARGS FUNCTION SELECTED IN THE CURRENT FUNCTION ARGS LIST BOX.

fig=ancestor(src,'figure','toplevel');

handles=getappdata(fig,'handles');
guiTab=getappdata(fig,'guiTab');
projectName=getappdata(fig,'projectName');

currVals=handles.fcnListBox.Value;

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

for i=1:length(currVals)

    currFile=[getappdata(fig,'codePath') guiTab '_' projectName slash 'Arguments' slash guiTab 'Arg_' currVals{i} '.m'];
    if exist(currFile,'file')==2
        edit(currFile);
    else
        templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'PerArgFunctionTemplate.m'];
        createFileFromTemplate(templatePath,currFile,[guiTab 'Arg_' currVals{i}]);
    end

end