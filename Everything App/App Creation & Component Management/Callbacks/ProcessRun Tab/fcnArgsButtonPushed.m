function []=fcnArgsButtonPushed(src)

%% PURPOSE: OPEN THE ARGS FUNCTION

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;
currLetter=src.Text;

if ~isletter(currTag(end-1)) % 2 digits
    elemNum=str2double(currTag(end-1:end));
else % 1 digit
    elemNum=str2double(currTag(end));
end

fcnNames=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
fcnNames=fcnNames.Value;

currFcn=fcnNames{elemNum};

fcnElems=strsplit(currFcn,' ');
fcnName=[fcnElems{1} '_Process' fcnElems{2}]; % Number & letter

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

argsFolder=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Function'];
addpath(argsFolder);

if exist(argsFolder,'dir')~=7
    mkdir(argsFolder);
end

argsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Function' slash fcnName '.m'];

if exist(argsPath,'file')==2
    edit(argsPath);
else % If the arguments file does not exist, create it from the template.
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'Process_argsTemplate.m'];
%     firstLine=['function [argsVars,argsPaths]=' fcnName '(projectStruct,subName,trialName,repNum)'];
    createFileFromTemplate(templatePath,argsPath,fcnName)
end