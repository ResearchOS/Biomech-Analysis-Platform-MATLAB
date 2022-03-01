function []=addConditionNameButtonPushed(src, event)

%% PURPOSE: ADD A NEW CONDITION TO THE CURRENT SPECIFYTRIALS FILE.

pguiFig=evalin('base','gui;');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=getappdata(pguiFig,'projectName');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Get the M file path
filePath=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash handles.Top.specifyTrialsDropDown.Value '_' projectName '_specifyTrials.m'];

% Get whether this is Include or Exclude criteria
type=handles.Top.includeExcludeTabGroup.SelectedTab.Title;

assert(exist(filePath,'file')==2);

a=0;
while a==0
    condName=inputdlg('Enter condition name');
    if isempty(condName)
        return;
    end
    condName=condName{1};
    if isvarname(condName)
        a=1;
    else
        disp('Invalid name. Must be valid MATLAB variable name!')
    end
end

logVar=load(getappdata(pguiFig,'LogsheetMatPath'));
fldName=fieldnames(logVar);
assert(length(fldName)==1);
logVar=logVar.(fldName{1});
headerRow=logVar(1,:);


% Read the M file to see what kind of conditions currently exist.
text=regexp(fileread(filePath),'\n','split'); % Read in the file

inclexclCond=0; % Initialize that there is no inclusion or exclusion criteria present
condNum=0;
lastLine=1;
for i=1:length(text)

    currLine=text{i}(~isspace(text{i}));

    if isempty(currLine)
        continue;
    end

    if length(currLine)>=length('inclStruct') && ~isequal(currLine(1:length('inclStruct')),'inclStruct')
        continue;
    end

    if length(currLine)>=18 && ismember(currLine(12:18),{'Include','Exclude'})
        inclexclCond=1;

        % Determine the condition number
        if isequal(currLine(12:18),type)
            condNum=str2double(currLine(isstrprop(currLine(1:35),'digit')));
        end

        lastLine=i;
    end

end

fcnText=text(1:lastLine)'; % Carry over everything prior to this new condition.

condNum=condNum+1; % Add one more condition
lineNum=lastLine+2; % The starting line number.

inclStructPrefix=['inclStruct.' type '.Condition(' num2str(condNum) ').Logsheet'];

fcnText{lineNum,1}=['inclStruct.' type '.Condition(' num2str(condNum) ').Name=''' condName ''';'];
% lineNum=lineNum+2;

count=0;
for i=lineNum:4:lineNum-1+length(headerRow)*4
    count=count+1;
    fcnText{i+2,1}=[inclStructPrefix '(' num2str(count) ').Name=''' headerRow{count} ''';']; % Name
    fcnText{i+3,1}=[inclStructPrefix '(' num2str(count) ').Value='''';']; % Value (empty by default)
    fcnText{i+4,1}=[inclStructPrefix '(' num2str(count) ').Logic=''ignore'';']; % Logic (ignore by default)
    fcnText{i+5,1}='';
end

if lastLine<length(text) && inclexclCond==1
    fcnText=[fcnText; text(lastLine+1:end)']; % Add back in everything else.
end

% Save the M file
fid=fopen(filePath,'w');
fprintf(fid,'%s\n',fcnText{1:end-1});
fprintf(fid,'%s',fcnText{end});
fclose(fid);

% Change the condition drop down list items and current name.
condNames=handles.(type).conditionDropDown.Items;
if length(condNames)==1 && isequal(condNames{1},'Add Condition Name')
    handles.(type).conditionDropDown.Items={condName};
else
    handles.(type).conditionDropDown.Items=[handles.(type).conditionDropDown.Items {condName}];
end

handles.(type).conditionDropDown.Value=condName;

% Update the inclStruct by reading the new file.
[~,name]=fileparts(filePath);
inclStruct=feval(name);
setappdata(fig,'inclStruct',inclStruct);

% Propagate the changes to the rows of the GUI.
conditionNameDropDownValueChanged(handles.(type).conditionDropDown);