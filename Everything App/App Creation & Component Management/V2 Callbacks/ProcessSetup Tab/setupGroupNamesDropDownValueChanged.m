function []=setupGroupNamesDropDownValueChanged(src,event)

%% PURPOSE: CHANGE THE FUNCTION NAMES IN THE FUNCTION NAMES TEXT AREA WHEN THE CURRENT GROUP DROP DOWN IS CHANGED

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fcnNamesFilePath=getappdata(fig,'fcnNamesFilePath');
[text]=readFcnNames(fcnNamesFilePath);
[groupNames,lineNums,mostRecentGroupName]=getGroupNames(text);

if isempty(mostRecentGroupName)
    hTextArea=handles.ProcessSetup.setupFunctionNamesField;
%     hTextArea=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
    hTextArea.Value='Function Names';
    return;
end

currGroupName=src.Value;
idx=ismember(groupNames,currGroupName); % The idx of the current group name

currLineNum=lineNums(idx); % The line number of the current group number
fcnNames={''};
for i=currLineNum+1:length(text)
    
    if isempty(text{i})
        break; % Finished iterating through the function names in this group
    end
    
    colonIdx=strfind(text{i},':'); % Get the index of the colon in each line
    
    if i==currLineNum+1 % First function name in this group
        fcnNames={text{i}(1:colonIdx-1)};
    else % Functions 2+ in this group
        fcnNames=[fcnNames; {text{i}(1:colonIdx-1)}];
    end
    
end

hTextArea=handles.ProcessSetup.setupFunctionNamesField;
% hTextArea=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
hTextArea.Value=fcnNames;
setappdata(fig,'functionNames',fcnNames);

% Set the most recent group name in the text file
for i=length(text):-1:1
    
    if length(text{i})>length('Most Recent Setup Group Name:') && isequal(text{i}(1:length('Most Recent Setup Group Name:')),'Most Recent Setup Group Name:')
        
        text{i}=['Most Recent Setup Group Name: ' currGroupName];
        
    end
    
end

fid=fopen(fcnNamesFilePath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);