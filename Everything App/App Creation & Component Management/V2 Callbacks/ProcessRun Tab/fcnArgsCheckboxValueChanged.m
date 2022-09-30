function []=fcnArgsCheckboxValueChanged(src)

%% PURPOSE: INDICATE WHETHER TO USE THE INDIVIDUAL FUNCTION'S ARGUMENTS FUNCTION. IF UNCHECKED, USE THE GROUP LEVEL ARGUMENTS FUNCTION

fig=ancestor(src,'figure','toplevel');

hRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupName=hRunDropDown.Value;

currTag=src.Tag;
currNum=str2double(currTag(length('FcnArgsCheckbox')+1:end));

% Get the current checkbox value
currVal=src.Value;

% If now unchecked, turn off visibility of args button
hArgsButton=findobj(fig,'Type','uibutton','Tag',['FcnArgsButton' num2str(currNum)]);
hArgsButton.Visible=currVal;

% Get current function name
currFcnButton=findobj(fig,'Type','uibutton','Tag',['OpenFcnButton' num2str(currNum)]);
currFcnName=currFcnButton.Text;
currFcnArgsButton=findobj(fig,'Type','uibutton','Tag',['FcnArgsButton' num2str(currNum)]);
currFcnArg=currFcnArgsButton.Text(isstrprop(currFcnArgsButton.Text,'alpha'));

currFullName=[currFcnName currFcnArg]; % The function name & method number & letter

% Read the function names text file
[text]=readFcnNames(getappdata(fig,'fcnNamesFilePath'));

% Get the group names
[groupNames,lineNums]=getGroupNames(text);
groupNum=ismember(groupNames,groupName);
lineNum=lineNums(groupNum);

% Search through the text file for the current group to store the checkbox value
currText=text{lineNum+currNum};
beforeColon=strsplit(currText,':');
beforeColon=beforeColon{1}(~isspace(beforeColon{1}));
if isequal(beforeColon,currFullName)
    colonIdx=strfind(currText,':');
    text{lineNum+currNum}=[currText(1:colonIdx+20) ' Args' num2str(currVal)];
end

% Save the text file
fid=fopen(getappdata(fig,'fcnNamesFilePath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);