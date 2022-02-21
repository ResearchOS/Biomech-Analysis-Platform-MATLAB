function []=runFcnCheckboxValueChanged(src)

%% PURPOSE: INDICATE (& SAVE TO FILE) WHETHER OR NOT TO RUN THIS FUNCTION

fig=ancestor(src,'figure','toplevel');

hRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupName=hRunDropDown.Value;

% Get current tag
currTag=src.Tag;
currNum=str2double(currTag(length('RunFcnCheckbox')+1:end)); % char

% Get the current checkbox value
currVal=src.Value;

% If now unchecked, turn off visibility of specify trials checkbox & button
hSpecifyTrialsCheckbox=findobj(fig,'Type','uicheckbox','Tag',['SpecifyTrialsCheckbox' num2str(currNum)]);
hSpecifyTrialsButton=findobj(fig,'Type','uibutton','Tag',['SpecifyTrialsButton' num2str(currNum)]);
hFcnArgsCheckbox=findobj(fig,'Type','uicheckbox','Tag',['FcnArgsCheckbox' num2str(currNum)]);
hFcnArgsCheckbox.Visible=currVal;
hSpecifyTrialsCheckbox.Visible=currVal;
if hSpecifyTrialsCheckbox.Value==1
    hSpecifyTrialsButton.Visible=1;
end

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
    text{lineNum+currNum}=[currText(1:colonIdx) ' Run' num2str(currVal) ' ' currText(colonIdx+7:end)];
end

% Save the text file
fid=fopen(getappdata(fig,'fcnNamesFilePath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);