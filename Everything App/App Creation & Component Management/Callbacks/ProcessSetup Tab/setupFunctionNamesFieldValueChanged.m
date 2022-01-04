function []=setupFunctionNamesFieldValueChanged(src,event)

%% PURPOSE: STORE THE FUNCTION NAMES, AND CHECK THEM TO MAKE SURE THERE'S A SPACE IN EACH ONE
% In the text area, the correct format is: 'fcnName #Letter'
% The processing function file name format is: 'fcnName_Process#'
% The function arguments file name format is: 'fcnName_ProcessLetter'

fig=ancestor(src,'figure','toplevel');

currNames=src.Value;

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Enter the code path first!');
    return;
end

if isempty(currNames{1})
    return; % Do nothing if the text area is empty
end

hGroupNamesDropDown=findobj(fig,'Type','uidropdown','Tag','SetupGroupNameDropDown');

if isequal(hGroupNamesDropDown.Value,'Create Group Name')
    disp('Create a group name first!');
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

for i=1:length(currNames)
    
    a=strsplit(strtrim(currNames{i}),' ');
    if length(a)==1
        disp(['Missing a space between function name and method number/letter: ' currNames{i}]);
        return;
    end
    
    if ~any(isletter(a{2}))
        disp(['Missing args letter in: ' currNames{i}]);
    end
    
    if ~any(~isletter(a{2}))
        disp(['Missing fcn number in: ' currNames{i}]);
    end
    
    % Check if the function exists, in 'Existing Functions' or 'User-Created Functions' folder
    existPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash a{1} '_Process' a{2}(~isletter(a{2})) '.m'];
    userPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'User-Created Functions' slash a{1} '_Process' a{2}(~isletter(a{2})) '.m'];
    
    if exist(existPath,'file')~=2 && exist(userPath,'file')~=2
        disp(['Function ' a{1} '_Process' a{2}(~isletter(a{2})) ' Does Not Exist']);
        return;
    end
    
    % Check that there are not two identical function names & method number/letter
    currName=currNames{i};
    for j=1:length(currNames)
        
        checkCurrName=currNames{j};
        if isequal(currName,checkCurrName) && ~isequal(i,j)
            disp(['Function ' checkCurrName ' Is a Multiple. Exists On Lines ' num2str(i) ' & ' num2str(j)]);
            return;
        end
        
    end
    
end

disp('Functions Staged:');
for i=1:length(currNames)
    
    disp(currNames{i});
    
end
disp(''); % To put a space at the end of the function names