function []=descriptionTextAreaValueChanged(src,event)

%% PURPOSE: STORE THE DESCRIPTION OF THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

descVal=handles.descriptionTextArea.Value;

assert(length(descVal)==1);
descVal=descVal{1};

currVals=handles.fcnListBox.Value;

argsNameInCode=getappdata(fig,'argsNameInCode');
argsDesc=getappdata(fig,'argsDesc');
argNames=getappdata(fig,'argNames');

fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
guiTab=getappdata(fig,'guiTab');

projectName=getappdata(fig,'projectName');

if length(currVals)>1
    handles.descriptionTextArea.Value='Mult';
    return;
end

idx=ismember(handles.fcnListBox.Items,currVals);
description=argsDesc{idx};
argName=argNames{idx};
currArgsNameInCode=argsNameInCode{idx};

if any(contains(descVal,char(13))) || any(contains(descVal,'newline'))
    warning('Newline chars not allowed!');
    return;
end

writeAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnName,argName,projectName,currArgsNameInCode,descVal);

argsDesc{idx}=descVal;
setappdata(fig,'argsDesc',argsDesc);