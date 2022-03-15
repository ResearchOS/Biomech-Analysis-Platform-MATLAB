function []=nameInCodeEditFieldValueChanged(src,event)

%% PURPOSE: STORE THE NAME IN CODE VALUE TO THE TEXT FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

nameInCodeVal=handles.nameInCodeEditField.Value;

currVals=handles.fcnListBox.Value;

argsNameInCode=getappdata(fig,'argsNameInCode');
argsDesc=getappdata(fig,'argsDesc');
argNames=getappdata(fig,'argNames');

fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
guiTab=getappdata(fig,'guiTab');

projectName=getappdata(fig,'projectName');

if length(currVals)>1
    handles.nameInCodeEditField.Value='Mult';
    return;
end

idx=ismember(handles.fcnListBox.Items,currVals);
description=argsDesc{idx};
argName=argNames{idx};
currArgsNameInCode=argsNameInCode{idx};

% Get the order of 1 and 0 for nameInCode to replicate it (changed when checkbox is checked)
if isempty(currArgsNameInCode)
    nameInCodeStr=['0 ' currArgsNameInCode ', 1 ']; % No value set yet        
else
    currArgsNameInCodeSplit=strsplit(currArgsNameInCode,',');
    beforeCommaSplit=strsplit(strtrim(currArgsNameInCodeSplit{1}),' ');
    afterCommaSplit=strsplit(strtrim(currArgsNameInCodeSplit{2}),' ');
    if length(beforeCommaSplit)>1
        beforeCommaVal=beforeCommaSplit{2};
    else
        beforeCommaVal='';
    end
    if length(afterCommaSplit)>1
        afterCommaVal=afterCommaSplit{2};
    else
        afterCommaVal='';
    end

    if isequal(strtrim(beforeCommaSplit{1}),'0') % Not synced
        nameInCodeStr=['0 ' nameInCodeVal ', 1 ' afterCommaVal];
        prevVal=beforeCommaVal;
    elseif isequal(strtrim(afterCommaSplit{1}),'1') % Synced
        nameInCodeStr=['0 ' beforeCommaVal ', 1 ' nameInCodeVal];
        prevVal=afterCommaVal;
    end    

    if ~isvarname(nameInCodeVal)
        warning('Name in Code must be valid variable name!');
        handles.nameInCodeEditField.Value=prevVal;
        return;
    end
end

writeAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnName,argName,projectName,nameInCodeStr,description);

nameInCode=getappdata(fig,'argsNameInCode');
nameInCode{idx}=nameInCodeStr;
setappdata(fig,'argsNameInCode',nameInCode);