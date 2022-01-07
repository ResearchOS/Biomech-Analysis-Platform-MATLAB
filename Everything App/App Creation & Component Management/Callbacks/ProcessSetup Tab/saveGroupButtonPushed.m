function []=saveGroupButtonPushed(src,event)

%% PURPOSE: SAVE THE CURRENT FUNCTION NAMES TO THE CURRENT GROUP IN THE TEXT FILE.

fig=ancestor(src,'figure','toplevel');

hTextArea=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
fcnNames=hTextArea.Value;

if isempty(fcnNames)
    return; % Do nothing if the function names is empty
end

% Read the project's group names text file
fcnNamesFilePath=getappdata(fig,'fcnNamesFilePath');

if isempty(fcnNamesFilePath)
    beep;
    warning('Enter the code path first!');
    return;
end

origText=readFcnNames(fcnNamesFilePath);

if isempty(origText)
    beep;
    warning('The function names file does not exist!');
    return;
end

hGroupNamesDropDown=findobj(fig,'Type','uidropdown','Tag','SetupGroupNameDropDown');
groupName=hGroupNamesDropDown.Value;

% Find the line number of the current group name.
groupNameFound=0; % Initialize that the group name was not found.
for i=1:length(origText)
    
    if length(origText{i})>=length(['Group Name: ' groupName]) && isequal(origText{i}(1:length(['Group Name: ' groupName])),['Group Name: ' groupName])
        groupNameFound=1;
        groupNameLineNum=i;
        continue;
    end
    
    if groupNameFound==1
        if isempty(origText{i}) % The current group is over
            endLineNum=i; % The line number of the space after the current group
            break;
        end
    end
    
end

setappdata(fig,'processRunArrowCount',0); % Reset the function names display when saving new function names

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end
listing=dir([getappdata(fig,'everythingPath') 'm File Library' slash 'Process' slash]); % All elements are folders, where folder names are function names (without number or letter)

text=origText(1:groupNameLineNum); % Everything up to the current group's name
for i=1:length(fcnNames)
    
    % Check if the function name & number/letter already existed in the text file
    fcnName=fcnNames{i}; % The current function name & number/letter
    fcnFound=0; % By default the function was not found in the existing text file
    for j=groupNameLineNum+1:endLineNum-1 % Iterate over each function name in the group
        currLineText=origText{j};
        if isequal(fcnName,currLineText(1:length(fcnName))) % The function name & method number/letter is found in this line
            fcnFound=1; % The function was found in the existing text file
            fcnFoundLineNum=j;
            break;
        end
    end
    
    if fcnFound==1 % If the function name & number/letter already existed in the text file
        currLine=strsplit(origText{fcnFoundLineNum},':'); % The text of the current line, split by the colon
        afterColon=strtrim(currLine{2});
        runAndSpecifyTrials=strsplit(afterColon,' ');
        fcnNamesText{i}=[fcnNames{i} ': Run' runAndSpecifyTrials{1}(end) ' SpecifyTrials' runAndSpecifyTrials{2}(end)];
    else
        fcnNamesText{i}=[fcnNames{i} ': Run1 SpecifyTrials0']; % Add a colon right after the function name & number/letter
    end
    
    fcnNameText=strsplit(fcnName,' ');
    currFcnFileName=[fcnNameText{1} '_Process' fcnNameText{2}(~isletter(fcnNameText{2})) '.m'];
    
    % Check if the function names exist in the GitHub repo. If so, copy it to the Process > Existing functions folder within the codePath
    if exist([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash currFcnFileName],'file')~=2
        copied=copyFileFromLib(fig,'Process',currFcnFileName); % Won't copy the file if it doesn't exist.
    end
    
end
text(groupNameLineNum+1:groupNameLineNum+length(fcnNamesText))=fcnNamesText;
text(groupNameLineNum+1+length(fcnNamesText):length(origText(endLineNum:length(origText)))+length(fcnNames)+groupNameLineNum)=origText(endLineNum:length(origText));

% Save the text file
fid=fopen(fcnNamesFilePath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Display that the functions were saved to the group
disp(['Functions Saved to Group: ' groupName]);
for i=1:length(fcnNames)
    disp([fcnNames{i}]);
end
disp(''); % Put a space at the end of the function names

%% If the Process > Setup drop down value is equal to the Process > Run drop down value, change the display on the Process > Run tab
hGroupNamesRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
if isequal(hGroupNamesDropDown.Value,hGroupNamesRunDropDown.Value)
    runGroupNameDropDownValueChanged(hGroupNamesRunDropDown);
end