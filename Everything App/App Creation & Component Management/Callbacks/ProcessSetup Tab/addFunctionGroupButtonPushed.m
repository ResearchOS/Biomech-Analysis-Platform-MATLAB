function []=addFunctionGroupButtonPushed(src,event)

%% PURPOSE: ADD A FUNCTION GROUP TO THE PROJECT'S FUNCTION GROUP TEXT FILE

fig=ancestor(src,'figure','toplevel');

fcnNamesFilePath=getappdata(fig,'fcnNamesFilePath');

if isempty(fcnNamesFilePath)
    beep;
    warning('Enter code path first!');
    return;
end

hGroupNamesDropDown=findobj(fig,'Type','uidropdown','Tag','SetupGroupNameDropDown');

groupName=inputdlg('Enter Group Name','New Group Name');
if isempty(groupName)
    figure(fig);
    return; % Cancel or 'X' was clicked.
end

groupName=groupName{1}; % Convert cell to char

if exist(fcnNamesFilePath,'file')~=2 % Check if the project's group names text file exists.
    
    text{1}=['Group Name: ' groupName];
    text{2}='';
    text{3}=['Most Recent Setup Group Name: ' groupName];
    text{4}=['Most Recent Run Group Name: ' groupName];
    
    hGroupNamesDropDown.Items={groupName};
    hGroupNamesDropDown.Value=groupName;
    
else % If the project's group names text file does exist.

    % Check if the group name already exists. If so, treat it as switching group names in drop down.
    if any(ismember(hGroupNamesDropDown.Items,{groupName}))
        setupGroupNamesDropDownValueChanged(hGroupNamesDropDown);
        return;
    end
    
    % Read text file
    origText=readFcnNames(fcnNamesFilePath);
    
    for lineNum=length(origText):-1:1
        
        if length(origText{lineNum})>length('Most Recent Setup Group Name:') && isequal(origText{lineNum}(1:length('Most Recent Setup Group Name:')),'Most Recent Setup Group Name:')
            
            text=origText(1:lineNum-2); % Up to the end of all existing groups
            text{lineNum-1}='';
            text{lineNum}=['Group Name: ' groupName];
            text{lineNum+1}='';
            text{lineNum+2}=['Most Recent Setup Group Name: ' groupName];
            text{lineNum+3}=['Most Recent Run Group Name: ' groupName];
            break;
            
        end
        
    end
    
    hGroupNamesDropDown.Items=[hGroupNamesDropDown.Items {groupName}];
    hGroupNamesDropDown.Value=groupName;
    
end

fid=fopen(fcnNamesFilePath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

% Set the run tab drop down list to have the same group names as the setup tab
hGroupNamesRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
hGroupNamesRunDropDown.Items=hGroupNamesDropDown.Items;