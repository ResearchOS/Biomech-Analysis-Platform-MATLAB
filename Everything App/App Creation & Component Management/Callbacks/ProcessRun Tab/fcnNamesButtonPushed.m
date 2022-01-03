function []=fcnNamesButtonPushed(src)

%% PURPOSE: OPEN (NOT CREATE) THE FUNCTION NAME ON THE BUTTON

% fcnName=src.Text;
currTag=src.Tag;
fig=ancestor(src,'figure','toplevel');

if ~isletter(currTag(end-1)) % 2 digits
    runNum=currTag(end-1:end);
else % 1 digit
    runNum=currTag(end);
end

% Get the text area values
fcnNames=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
fcnNames=fcnNames.Value;
currFcn=fcnNames{str2double(runNum)}; % The corresponding entry from the text area in the Process > Setup tab

fcnElems=strsplit(currFcn,' ');
fcnName=[fcnElems{1} '_Process' fcnElems{2}(~isletter(fcnElems{2}))];

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