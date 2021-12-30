function []=runGroupNameDropDownValueChanged(src,event)

%% PURPOSE: WRITE THE NEW RUN GROUP NAME TO THE TEXT FILE, AND CHANGE THE DISPLAY TO THE NEW FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');

groupName=src.Value;
text=readFcnNames(getappdata(fig,'fcnNamesFilePath'));

for i=length(text):-1:1
    
    if length(text{i})>length('Most Recent Run Group Name:') && isequal(text{i}(1:length('Most Recent Run Group Name:')),'Most Recent Run Group Name:')
        text{i}=['Most Recent Run Group Name: ' groupName];
        break;
    end
    
end

% Save the text file
if ~isempty(text)
    fid=fopen(getappdata(fig,'fcnNamesFilePath'),'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
end

%% SET THE FOLLOWING GROUP-LEVEL COMPONENTS:
% SPECIFY TRIALS BUTTON
% GROUP LEVEL SPECIFY TRIALS CHECKBOX

%% CREATE & POSITION THE FOLLOWING COMPONENTS FOR EACH FUNCTION:
% FUNCTION NAME BUTTONS
% FUNCTION ARGS BUTTONS
% SPECIFY TRIALS BUTTONS
% RUN FUNCTION CHECKBOXES
% FUNCTION LEVEL SPECIFY TRIALS CHECKBOXES

[groupNames,lineNums]=getGroupNames(text);
groupNum=ismember(groupNames,groupName);
lineNum=lineNums(groupNum);

fcnNames=getappdata(fig,'functionNames');
% processRunPanel=findobj(fig,'Tag','Run');
processRunPanel=findobj(fig,'Type','uipanel','Tag','RunFunctionsPanel');

% Delete the components first
elemNum=0;
allEntries=0; % Indicates that not all elements have been found
while allEntries==0
    
    elemNum=elemNum+1;
    
    currRunFcnCheckbox=findobj(processRunPanel,'Type','uicheckbox','Tag',['RunFcnCheckbox' num2str(elemNum)]);
    currFcnNamesButton=findobj(processRunPanel,'Type','uibutton','Tag',['OpenFcnButton' num2str(elemNum)]);
    currFcnArgsButton=findobj(processRunPanel,'Type','uibutton','Tag',['FcnArgsButton' num2str(elemNum)]);
    currSpecifyTrialsCheckbox=findobj(processRunPanel,'Type','uicheckbox','Tag',['SpecifyTrialsCheckbox' num2str(elemNum)]);
    currSpecifyTrialsButton=findobj(processRunPanel,'Type','uibutton','Tag',['SpecifyTrialsButton' num2str(elemNum)]);
    if ~isempty(currRunFcnCheckbox) && ~isempty(currFcnNamesButton) && ~isempty(currFcnArgsButton) && ~isempty(currSpecifyTrialsCheckbox) && ~isempty(currSpecifyTrialsButton)
        delete(currRunFcnCheckbox);
        delete(currFcnNamesButton);
        delete(currFcnArgsButton);
        delete(currSpecifyTrialsCheckbox);
        delete(currSpecifyTrialsButton);
    else
        allEntries=1;
    end
    
end

% Create the components after deleting them
elemNum=0;
for i=1:length(fcnNames)
    
    elemNum=elemNum+1;
    tagNameCell=strsplit(fcnNames{i},' ');
    tagName=[tagNameCell{1} tagNameCell{2}(~isletter(tagNameCell{2}))];
    fullName=[tagName tagNameCell{2}(isletter(tagNameCell{2}))];
    
    currLine=text{lineNum+i};
    afterColon=strsplit(currLine,':');
    runAndSpecifyTrials=strsplit(strtrim(afterColon{2}),' ');
    
    % Check the 'Run' checkbox status in the text file
    runStatus=str2double(runAndSpecifyTrials{1}(end));
    
    % Check the 'SpecifyTrials' checkbox status in the text file
    specifyTrialsStatus=str2double(runAndSpecifyTrials{2}(end));
    
    % Run function checkboxes
    runFcnCheckbox=uicheckbox(processRunPanel,'Text','','Value',runStatus,'Tag',['RunFcnCheckbox' num2str(elemNum)]);
    
    % Function names button
    fcnNamesButton=uibutton(processRunPanel,'Text',tagName,'Tag',['OpenFcnButton' num2str(elemNum)]);
    
    % Function args button
    fcnArgsButton=uibutton(processRunPanel,'Text',tagNameCell{2}(isletter(tagNameCell{2})),'Tag',['FcnArgsButton' num2str(elemNum)]);
    
    % Specify trials checkbox
    specifyTrialsCheckbox=uicheckbox(processRunPanel,'Text','','Value',specifyTrialsStatus,'Tag',['SpecifyTrialsCheckbox' num2str(elemNum)]);
    
    % Specify trials button
    specifyTrialsButton=uibutton(processRunPanel,'push','Text','Specify Trials','Tag',['SpecifyTrialsButton' num2str(elemNum)]);
    
    % Set the ValueChangedFcn
    set(runFcnCheckbox,'ValueChangedFcn',@(runFcnCheckbox,event) runFcnCheckboxValueChanged(runFcnCheckbox));
    set(fcnNamesButton,'ButtonPushedFcn',@(fcnNamesButton,event) fcnNamesButtonPushed(fcnNamesButton));
    set(fcnArgsButton,'ButtonPushedFcn',@(fcnArgsButton,event) fcnArgsButtonPushed(fcnArgsButton));
    set(specifyTrialsCheckbox,'ValueChangedFcn',@(specifyTrialsCheckbox,event) specifyTrialsCheckboxValueChanged(specifyTrialsCheckbox));
    set(specifyTrialsButton,'ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushed(specifyTrialsButton));
    
    processRunPanel.UserData.(['RunFcnCheckbox' num2str(elemNum)])=runFcnCheckbox;
    processRunPanel.UserData.(['OpenFcnButton' num2str(elemNum)])=fcnNamesButton;
    processRunPanel.UserData.(['FcnArgsButton' num2str(elemNum)])=fcnArgsButton;
    processRunPanel.UserData.(['SpecifyTrialsCheckbox' num2str(elemNum)])=specifyTrialsCheckbox;
    processRunPanel.UserData.(['SpecifyTrialsButton' num2str(elemNum)])=specifyTrialsButton;
    
end

hLogsheetPathField=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
processRunPanel.UserData.LogsheetPathField=hLogsheetPathField;

processRunPanelResize(processRunPanel);