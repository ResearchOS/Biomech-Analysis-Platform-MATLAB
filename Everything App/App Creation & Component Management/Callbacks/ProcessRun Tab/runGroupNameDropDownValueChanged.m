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

fcnCount=0;
for i=lineNum+1:length(text) % Start with first function name
    
    if isempty(text{i})
        break;
    end
    
    currLine=strsplit(text{i},':');
    currFcn=strsplit(currLine{1},' ');
    
    fcnCount=fcnCount+1;
    fcnNames{fcnCount}=[currFcn{1} '_Process' currFcn{2}(~isletter(currFcn{2}))];
    argsNames{fcnCount}=[currFcn{1} '_Process' currFcn{2}];
    
end

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
        
        processRunPanel.UserData=rmfield(processRunPanel.UserData,['RunFcnCheckbox' num2str(elemNum)]);
        processRunPanel.UserData=rmfield(processRunPanel.UserData,['OpenFcnButton' num2str(elemNum)]);
        processRunPanel.UserData=rmfield(processRunPanel.UserData,['FcnArgsButton' num2str(elemNum)]);
        processRunPanel.UserData=rmfield(processRunPanel.UserData,['SpecifyTrialsCheckbox' num2str(elemNum)]);
        processRunPanel.UserData=rmfield(processRunPanel.UserData,['SpecifyTrialsButton' num2str(elemNum)]);
    else
        allEntries=1;
    end
    
end

if isempty(text)
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Create the components after deleting them
if exist('fcnNames','var')==1
    elemNum=0;
    for i=1:length(fcnNames)
        
        elemNum=elemNum+1;
        tagNameCell=strsplit(fcnNames{i},'_Process');
        tagName=[tagNameCell{1} tagNameCell{2}];
        argsName=strsplit(argsNames{i},'_Process');
        argLetter=argsName{2};
        
        currLine=text{lineNum+i};
        afterColon=strsplit(currLine,':');
        runAndSpecifyTrials=strsplit(strtrim(afterColon{2}),' ');
        
        % Check that the function exists. If not, stop execution
        fcnName=strsplit(afterColon{1},' ');
        fullName=[fcnName{1} '_Process' tagNameCell{2}(~isletter(tagNameCell{2}))];
        fullExistPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash fullName '.m'];
        fullUserPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'User-Created Functions' slash fullName '.m'];
        
        if exist(fullExistPath,'file')~=2 && exist(fullUserPath,'file')~=2
            disp([fullName ' Not Found']);
            return;
        end
        
        % Check the 'Run' checkbox status in the text file
        runStatus=str2double(runAndSpecifyTrials{1}(end));
        
        % Check the 'SpecifyTrials' checkbox status in the text file
        specifyTrialsStatus=str2double(runAndSpecifyTrials{2}(end));
        
        % Run function checkboxes
        runFcnCheckbox=uicheckbox(processRunPanel,'Text','','Value',runStatus,'Tag',['RunFcnCheckbox' num2str(elemNum)]);
        
        % Function names button
        fcnNamesButton=uibutton(processRunPanel,'Text',tagName,'Tag',['OpenFcnButton' num2str(elemNum)]);
        
        % Function args button
        fcnArgsButton=uibutton(processRunPanel,'Text',argLetter,'Tag',['FcnArgsButton' num2str(elemNum)]);
        
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
    
    setappdata(fig,'processRunArrowCount',0); % Reset the function row scrolling
    
    processRunPanelResize(processRunPanel);
end