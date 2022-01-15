function []=newFunctionButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESSING FUNCTION FROM TEMPLATE.
% template file path: [everythingPath 'Project-Independent-Templates slash 'Process_' level 'Template]
% new file path: [codePath 'Process_' projectName slash 'User-Created Functions' slash fcnName '_Process' number]

fig=ancestor(src,'figure','toplevel');

% Decide which template to copy from, based on the level of inputs selected. Use the lowest level selected (total of 3 templates)
hInputCheckboxP=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxProject');
hInputCheckboxS=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxSubject');
hInputCheckboxT=findobj(fig,'Type','uicheckbox','Tag','InputCheckboxTrial');

if hInputCheckboxT.Value==0 && hInputCheckboxS.Value==0 && hInputCheckboxP.Value==0
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

relativeName=[fcnName '_Process' fcnNum '.m'];

% Check if the function names exist in the GitHub repo. If so, copy it to the Process > Existing functions folder within the codePath
copied=copyFileFromLib(fig,'Process',relativeName);

if copied==1 % Function did exist in the library
    filePathExist=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Existing Functions' slash fcnName '_Process' fcnNum '.m'];
    disp(['Function ' fcnName '_Process' fcnNum ' Copied From Function Library']);
    edit(filePathExist);
    return;
end

% Function did not exist in the library, create a new one from template.
filePathUser=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'User-Created Functions' slash fcnName '_Process' fcnNum '.m'];

% Assign inputs levels
levelsIn='';
if hInputCheckboxP.Value==1 % Has inputs that change once per project
    levelsIn='P';
end
if hInputCheckboxS.Value==1 % Has inputs that change once per subject
    levelsIn=[levelsIn 'S'];
end
if hInputCheckboxT.Value==1 % Has inputs that change once per trial
    if hInputCheckboxS.Value==0 && hInputCheckboxP.Value==1
        levelsIn=[levelsIn 'ST']; % Even if the subject checkbox wasn't checked, need to iterate over subjects anyways to iterate over trials when project level is used.
    else
        levelsIn=[levelsIn 'T'];
    end
end

templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'Process_Template' levelsIn '.m'];

wholeFcnName=[fcnName '_Process' fcnNum];

% firstLine=['function [dataOut]=' fcnName '_Process' fcnNum '(methodLetter,subName,trialName,varargin)'];

% Create the new file
createFileFromTemplate(templatePath,filePathUser,wholeFcnName);