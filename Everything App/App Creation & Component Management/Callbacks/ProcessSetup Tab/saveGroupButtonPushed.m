function []=saveGroupButtonPushed(src,event)

%% PURPOSE: SAVE THE CURRENT FUNCTION NAMES TO THE CURRENT GROUP IN THE TEXT FILE.

fig=ancestor(src,'figure','toplevel');

fcnNames=getappdata(fig,'functionNames');

if isempty(fcnNames)
    return; % Do nothing if the function names is empty
end

% Read the project's group names text file
fcnNamesFilePath=getappdata(fig,'fcnNamesFilePath');

origText=readFcnNames(fcnNamesFilePath);

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
            
            endLineNum=i; % The line number of the space between the end of the current group and 
            break;
            
        end
        
    end
    
end

fcnNames=getappdata(fig,'functionNames');

text=origText(1:groupNameLineNum); % Everything up to the current group's name
text(groupNameLineNum+1:groupNameLineNum+length(fcnNames))=fcnNames;
text(groupNameLineNum+1+length(fcnNames):length(origText(endLineNum:length(origText)))+length(fcnNames)+groupNameLineNum)=origText(endLineNum:length(origText));

% Save the text file
fid=fopen(fcnNamesFilePath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Display that the functions were saved to the group
disp(['Functions Staged to Group: ' groupName]);
for i=1:length(fcnNames)
    disp([fcnNames{i}]);
end

%% If the Process > Setup drop down value is equal to the Process > Run drop down value, change the display on the Process > Run tab
hGroupNamesRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
if isequal(hGroupNamesDropDown.Value,hGroupNamesRunDropDown.Value)
    runGroupNameDropDownValueChanged();
end