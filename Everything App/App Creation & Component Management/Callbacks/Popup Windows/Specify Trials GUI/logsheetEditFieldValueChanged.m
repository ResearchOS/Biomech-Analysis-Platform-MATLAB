function []=logsheetEditFieldValueChanged(src)

%% PURPOSE: STORE TO THE INCLSTRUCT THE CHANGE IN THE TEXT FIELDS IN THE LOGSHEET SUBTAB

value=src.Value;
fig=ancestor(src,'figure','toplevel');
inclStruct=getappdata(fig,'inclStruct');
handles=getappdata(fig,'handles');

type=handles.Top.includeExcludeTabGroup.SelectedTab.Title;

condNum=find(ismember(handles.(type).conditionDropDown.Items,handles.(type).conditionDropDown.Value)==1,1);

srcNum=str2double(src.Tag(isstrprop(src.Tag,'digit')));

subTabTitle=handles.(type).logStructTabGroup.SelectedTab.Title;

inclStruct.(type).Condition(condNum).Logsheet(srcNum).Value=value;

setappdata(fig,'inclStruct',inclStruct);

% Get the m file name
mName=getappdata(fig,'specifyTrialsMPath');

% Read through every line to find where it matches the current criteria name, and replace the logic value.
text=regexp(fileread(mName),'\n','split'); % Read in the file, where each line is one cell.

toMatch=['inclStruct.' type '.Condition(' num2str(condNum) ').' subTabTitle '(' num2str(srcNum) ').Value'];
for i=1:length(text)

    if length(text{i})>=length(toMatch) && isequal(text{i}(1:length(toMatch)),toMatch)
        text{i}=[toMatch '=''' value ''';'];
        break;
    end

end

% Save the m file
fid=fopen(mName,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);