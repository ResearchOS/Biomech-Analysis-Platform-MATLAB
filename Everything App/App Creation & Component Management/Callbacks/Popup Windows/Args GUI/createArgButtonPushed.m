function []=createArgButtonPushed(src,event)

%% PURPOSE: ADD NEW ARG TO THE ALL ARGS LIST, UPDATE THE LIST BOXES.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

nameInGUIOK=0;
defaultNameInCodeOK=0;

%% 0. Get the path to the VariablesMainList file.
matVarPath=[getappdata(fig,'dataPath') slash 'MAT Data Files' slash 'VariablesMainList.mat'];

%% Prompt for the name of the argument as shown in the GUI
while ~nameInGUIOK
    % 1. Open a dialog box asking for the name to use for the argument
    nameInGUI=inputdlg('Enter argument name in GUI');

    if isempty(nameInGUI) || isempty(nameInGUI{1})
        disp('Process cancelled, no argument added');
        return; % Operation cancelled or nothing entered.
    end

    nameInGUI=nameInGUI{1};

    nameInGUI=strtrim(nameInGUI);
    nameInGUI(isspace(nameInGUI))='_'; % Replace spaces with underscores

    if ~isvarname(nameInGUI)
        beep;
        disp('Try again, invalid argument name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(nameInGUI)>namelengthmax-3 % Minus 3 because of the underscore and hard-coded and level identifiers in the name.
        beep;
        disp(['Try again, argument name too long! Must be less than or equal to ' num2str(namelengthmax-3) ' characters, but is currently ' num2str(length(nameInGUI)) ' characters!']);
        continue;
    end

    % 2. Check if this argument name already exists in the list.
    if exist(matVarPath,'file')==2
        varNames=load(matVarPath,'-mat','VariableNamesOnly');
        if ismember(nameInGUI,varNames)
            disp('This variable already exists! No argument added, try again.');
            continue;
        end
    else
        varNames={};
    end

    nameInGUIOK=1;
end

%% Prompt for the default name of the argument in the code.
while ~defaultNameInCodeOK
    % 3. Ask for a default name in the code to use when adding a variable to a function.
    input2=inputdlg('Enter default argument name in code (leave blank to not provide default)');
    if isempty(input2)
        disp('Process cancelled, no argument added');
        return;
    end
    if isempty(input2{1})
        defaultName='';
    else
        defaultName=input2{1};
    end

    if ~isvarname(defaultName)
        beep;
        disp('Improper argument name! Spaces are ok, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(defaultName)>namelengthmax
        beep;
        disp(['Argument name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(defaultName)) ' characters!']);
        continue;
    end
end

%% 4. Ask whether the variable will be hard-coded
input3=questdlg('Is this a hard-coded variable?','Hard-coded variable?','Yes','No','No');
if isempty(input3)
    disp('Process cancelled, no argument added');
    return;
end

switch input3{1}
    case 'Yes'
        isHC='Y';
    case 'No'
        isHC='N';
end

%% 5. Ask what level the variable will be stored at (Project, Subject, or Trial)
input4=questdlg({'Project, Subject, or Trial level variable?','This can be changed later.'},'Variable Level','Project','Subject','Trial','Trial');
if isempty(input4)
    disp('Process cancelled, no argument added');
    return;
end

switch input4{1}
    case 'Project'
        level='P';
    case 'Subject'
        level='S';
    case 'Trial'
        level='T';
end

% 6. Add this variable to the GUI
[varNames,k]=sort([upper(varNames); upper(nameInGUI)]);
VariableNamesOnly=varNames(k,1);
setappdata(fig','AllVariableNames',VariableNamesOnly);
% Update all of the list boxes full of variable names! On Import, Process, Plot, and Stats tabs!
% updateListBoxes(handles,VariableNamesOnly,isHC,level);

% 7. Now, add this variable to the VariablesMainList
varName.DefaultNameInCode=defaultName;
varName.NameInGUI=nameInGUI;
varName.Level=input4{1};
if isequal(input3{1},'Yes')
    varName.IsHardcoded=true;
    % Create and store here the name of the .m file.
    hardcodedPath=[getappdata(fig,'codePath') 'Hardcoded M Files' slash nameInGUI '.m'];
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'PerArgFunctionTemplate.m'];
    createFileFromTemplate(templatePath,hardcodedPath,nameInGUI);
else
    varName.IsHardcoded=false;
end

eval([nameInGUI '=varName;']); % Create the variable name

if exist(matVarPath,'file')==2
    save(matVarPath,eval(nameInGUI),'VariableNamesOnly','-v6','-append'); % Save the variable to the file.
else
    save(matVarPath,eval(nameInGUI),'VariableNamesOnly','-v6'); % Save the variable to the file.
end