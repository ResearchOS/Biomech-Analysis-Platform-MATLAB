function []=addFunctionGroupButtonPushed(src,event)

%% PURPOSE: ADD A FUNCTION GROUP TO THE PROJECT'S FUNCTION GROUP TEXT FILE

fig=ancestor(src,'figure','toplevel');

hGroupNamesDropDown=findobj(fig,'Type','uidropdown','Tag','SetupGroupNameDropDown');

groupName=inputdlg('Enter Group Name','New Group Name');
if isempty(groupName)
    return; % Cancel or 'X' was clicked.
end

groupName=groupName{1}; % Convert cell to char

fcnNamesFilePath=[getappdata(fig,'codePath') 'functionNames_' getappdata(fig,'projectName') '.txt'];

if exist(fcnNamesFilePath,'file')~=2 % Check if the project's group names text file exists.
    
    text{1}=['Group Name: ' groupName];
    text{2}='';
    text{3}=['Most Recent Group Name: ' groupName];
    
    hGroupNamesDropDown.Items={groupName};
    hGroupNamesDropDown.Value=groupName;
    
else % If the project's group names text file does exist.
    
    % CHECK IF THE GROUP NAME ALREADY EXISTS. IF SO, TREAT IT AS SWITCHING GROUP NAMES IN DROP DOWN.
    
    % Read text file
    origText=readFcnNames(fcnNamesFilePath);
    
    for lineNum=length(origText):-1:1
        
        if length(origText{lineNum})>length('Most Recent Group Name:') && isequal(origText{lineNum}(1:length('Most Recent Group Name:')),'Most Recent Group Name:')
            
            text=origText{1:lineNum-2}; % Up to the end of all existing groups
            text{lineNum-1}='';
            text{lineNum}=['Group Name: ' groupName];
            text{lineNum+1}='';
            text{lineNum+2}=['Most Recent Group Name: ' groupName];
            
        end
        
    end
    
    hGroupNamesDropDown.Items=[hGroupNamesDropDown.Items {groupName}];
    hGroupNamesDropDown.Value=groupName;
    
end

fid=fopen(fcnNamesFilePath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Set the group names drop down