function []=logicDropDownValueChanged(src)

%% PURPOSE: IN THE INCLSTRUCT, CHANGE THE LOGIC USED FOR A SPECIFIC CRITERIA IN THE SPECIFY TRIALS
% Works for structure or logsheet drop-downs

value=src.Value;
fig=ancestor(src,'figure','toplevel');
% inclStruct=getappdata(fig,'inclStruct');
handles=getappdata(fig,'handles');
pguiFig=evalin('base','gui;');

slash=filesep;

verName=handles.Top.specifyTrialsDropDown.Value;
inclStruct=eval(verName);

type=handles.Top.includeExcludeTabGroup.SelectedTab.Title;

condNum=find(ismember(handles.(type).conditionDropDown.Items,handles.(type).conditionDropDown.Value)==1,1);

subTabTitle=handles.(type).logStructTabGroup.SelectedTab.Title;

srcNum=str2double(src.Tag(isstrprop(src.Tag,'digit')));

inclStruct.(type).Condition(condNum).(subTabTitle)(srcNum).Logic=value;

% setappdata(fig,'inclStruct',inclStruct);

% Get the m file name
mName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash verName '.m'];

% Read through every line to find where it matches the current criteria name, and replace the logic value.
text=regexp(fileread(mName),'\n','split'); % Read in the file, where each line is one cell.

toMatch=['inclStruct.' type '.Condition(' num2str(condNum) ').' subTabTitle '(' num2str(srcNum) ').Logic'];
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