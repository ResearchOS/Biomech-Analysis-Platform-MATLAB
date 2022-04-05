function []=fcnListBoxValueChanged(src,event)

%% PURPOSE: DISPLAY THE METADATA ASSOCIATED WITH THE CURRENTLY SELECTED ARGUMENT IN THE FUNCTION LIST BOX. IF MULTIPLE SELECTED, DO NOT DISPLAY ANYTHING.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currVals=handles.fcnListBox.Value;
guiTab=getappdata(fig,'guiTab');
groupName=getappdata(fig,'groupName');
fcnName=getappdata(fig,'fcnName');

text=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),guiTab);
[argNames,argsNamesInCode,argsDescs]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,groupName,fcnName);

% argsNameInCode=getappdata(fig,'argsNameInCode');
% argsDesc=getappdata(fig,'argsDesc');

if length(currVals)>1 % Multiple items selected, clear the edit fields
    handles.fullNicknameEditField.Value='Mult';
    handles.nameInCodeEditField.Value='Mult';
    handles.descriptionTextArea.Value='Mult';
else
%     idx=ismember(handles.fcnListBox.Items,currVals);
    handles.fullNicknameEditField.Value=currVals{1};
    if isequal(currVals{1},'No Args')
        return;
    end
    idx=ismember(argNames,currVals);
    currArgsNameInCode=argsNamesInCode{idx};
    argsDesc=argsDescs{idx};
%     currArgsNameInCode=argsNameInCode{idx};
    if isempty(currArgsNameInCode)
        handles.nameInCodeEditField.Value=currArgsNameInCode; % No value set yet
    else
        % Parse the values for group synced/not group synced to properly display the value
        % If 0 occurs before 1, var is not synced. If 1 occurs before 0, var is synced.
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
%             nameInCodeStr=['0 ' beforeCommaVal ', 1 ' afterCommaVal];
            useVal=beforeCommaVal;
        elseif isequal(strtrim(afterCommaSplit{1}),'1') % Synced
%             nameInCodeStr=['0 ' beforeCommaVal ', 1 ' afterCommaVal];
            useVal=afterCommaVal;
        end
        handles.nameInCodeEditField.Value=useVal;
    end
    handles.descriptionTextArea.Value=argsDesc;
end

