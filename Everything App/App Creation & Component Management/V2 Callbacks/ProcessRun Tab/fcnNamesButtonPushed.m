function []=fcnNamesButtonPushed(src)

%% PURPOSE: OPEN (NOT CREATE) THE FUNCTION NAME ON THE BUTTON

% fcnName=src.Text;
currTag=src.Tag;
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~isletter(currTag(end-1)) % 2 digits
    runNum=currTag(end-1:end);
else % 1 digit
    runNum=currTag(end);
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
    
    if isempty(text{i})
        break; % Finished iterating through the function names in this group
    end

    fcnCount=fcnCount+1;
    
    colonIdx=strfind(text{i},':'); % Get the index of the colon in each line

    if fcnCount<str2double(runNum)
        continue;
    end

    fcnName=text{i}(1:colonIdx-1);
    fcnNameSplit=strsplit(fcnName,' ');

    fcnName=[fcnNameSplit{1} '_Process' fcnNameSplit{2}(isstrprop(fcnNameSplit{2},'digit'))];
    
    break;
    
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fcnPathExist=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash fcnName '.m'];

fcnPathUser=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'User-Created Functions' slash fcnName '.m'];

if exist(fcnPathExist,'file')==2
    pathName=fcnPathExist;
else % If in user-created functions folder, or if does not yet exist.
    pathName=fcnPathUser;
end

try
    edit(pathName); % All functions should have been existing already
catch
    disp([fcnName ' Not Found']);
end