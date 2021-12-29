function []=runGroupNameDropDownValueChanged(src,event)

%% PURPOSE: WRITE THE NEW RUN GROUP NAME TO THE TEXT FILE, AND CHANGE THE DISPLAY TO THE NEW FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');

groupName=src.Value;
text=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
% [groupNames,lineNums,mostRecentSetupGroupName,mostRecentRunGroupName]=getGroupNames(text);

for i=length(text):-1:1
    
    if length(text{i})>length('Most Recent Run Group Name:') && isequal(text{i}(1:length('Most Recent Run Group Name:')),'Most Recent Run Group Name:')
        text{i}=['Most Recent Run Group Name: ' groupName];
        return;
    end
    
end

% Save the text file
fid=fopen(getappdata(fig,'fcnNamesFilePath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);