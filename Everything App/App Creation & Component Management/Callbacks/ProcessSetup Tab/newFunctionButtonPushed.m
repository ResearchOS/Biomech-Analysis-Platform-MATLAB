function []=newFunctionButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESSING FUNCTION FROM TEMPLATE.
% template file path: [everythingPath 'Project-Independent-Templates slash 'Process_' level 'Template]
% new file path: [codePath 'Process_' projectName slash 'User-Created Functions' slash fcnName '_Process' number]

fig=ancestor(src,'figure','toplevel');

% Decide which template to copy from, based on the level of inputs selected. Use the lowest level selected (total of 3 templates)
hProjectCheckbox=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxProject');
hSubjectCheckbox=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxSubject');
hTrialCheckbox=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxTrial');

if hTrialCheckbox.Value==0 && hSubjectCheckbox.Value==0 && hProjectCheckbox.Value==0
    disp(['Need to specify some level of input argument with the checkboxes!']);
    return;
end

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Enter the code path first!');
    return;
end

name=inputdlg('Enter Function Name, Format: ''fcnName #''');
if isempty(name) || isempty(name{1})
    return; % If Cancel or 'X' was clicked, or OK was clicked while the dialog box was empty
end

nameCell=strsplit(strtrim(name{1}),' '); % Split fcn name and number

if length(nameCell)~=2 || ~isvarname(nameCell{1}) % Check entry
    disp('Improper function name entered');
    return;
end
fcnName=nameCell{1}; % Function name
fcnNum=nameCell{2}; % Method number

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

wholeName=[fcnName '_Process' fcnNum '.m'];

% Check if the function names exist in the GitHub repo. If so, copy it to the Process > Existing functions folder within the codePath
copied=copyFileFromLib(fig,'Process',wholeName);

if copied==1 % Function did exist in the library
    filePathExist=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash fcnName '_Process' fcnNum '.m'];
    disp(['Function ' fcnName '_Process' fcnNum ' Copied From Function Library']);
    edit(filePathExist);
    return;
end

% Function did not exist in the library, create a new one from template.
filePathUser=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'User-Created Functions' slash fcnName '_Process' fcnNum '.m'];

if hProjectCheckbox.Value==1 % Has inputs that change only once per project
    level='project';
end
if hProjectCheckbox.Value==0 && hSubjectCheckbox.Value==1 % Has inputs that change only once per subject
    level='subject';
end
if hTrialCheckbox.Value==1 && hSubjectCheckbox.Value==0 && hProjectCheckbox.Value==0 % Has inputs that change only once per trial
    level='trial';
end

templatePath=[getappdata(fig,'everythingPath') 'Project-Independent-Templates' slash 'Process_' level 'Template'];

firstLine=['function [argsOut]=' fcnName '_Process' fcnNum '(argsIn)'];

% Create the new file
createFileFromTemplate(templatePath,filePathUser,firstLine);