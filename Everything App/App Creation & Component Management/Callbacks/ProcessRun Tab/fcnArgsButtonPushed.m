function []=fcnArgsButtonPushed(src)

%% PURPOSE: OPEN THE ARGS FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTag=src.Tag;

if ~isletter(currTag(end-1)) % 2 digits
    elemNum=str2double(currTag(end-1:end));
else % 1 digit
    elemNum=str2double(currTag(end));
end

runGroupDropDown=handles.ProcessRun.runGroupNameDropDown;
currGroup=runGroupDropDown.Value;

fcnNamesFilePath=getappdata(fig,'fcnNamesFilePath');
[text]=readFcnNames(fcnNamesFilePath);
[groupNames,lineNums,mostRecentGroupName]=getGroupNames(text);

idx=ismember(groupNames,currGroup); % The idx of the current group name

currLineNum=lineNums(idx); % The line number of the current group number
fcnNames={''};
fcnCount=0;
for i=currLineNum+1:length(text)

    fcnCount=fcnCount+1;
    
    if isempty(text{i})
        break; % Finished iterating through the function names in this group
    end
    
    colonIdx=strfind(text{i},':'); % Get the index of the colon in each line

    if fcnCount<elemNum
        continue;
    end

    fcnName=text{i}(1:colonIdx-1);
    fcnNameSplit=strsplit(fcnName,' ');

    fcnName=[fcnNameSplit{1} '_Process' fcnNameSplit{2}];
    
    break;
    
end

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