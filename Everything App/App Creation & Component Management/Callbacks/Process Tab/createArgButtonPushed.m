function []=createArgButtonPushed(src,event)

%% PURPOSE: ADD NEW ARG TO THE ALL ARGS LIST, UPDATE THE LIST BOXES.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.splitsUITree.SelectedNodes)
    beep;
    disp('Need to select a split to associate the variable to!');
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

nameInGUIOK=0;
defaultNameInCodeOK=0;

%% 0. Get the path to the VariablesMainList file.
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
if ismember('VariableNamesList',varNames)
    load(projectSettingsMATPath,'Digraph','VariableNamesList','NonFcnSettingsStruct');
    guiNames=VariableNamesList.GUINames;
else
    guiNames={''};
end

%% Prompt for the name of the argument as shown in the GUI
while ~nameInGUIOK
    % 1. Open a dialog box asking for the name to use for the argument
%     nameInGUI=inputdlg('Enter argument name in GUI');
    nameInGUI=input('Enter argument name in GUI: '); % Avoids the inputdlg

    if isempty(nameInGUI) || (iscell(nameInGUI) && isempty(nameInGUI{1}))
        disp('Process cancelled, no argument added');
        return; % Operation cancelled or nothing entered.
    end

    if iscell(nameInGUI)
        nameInGUI=nameInGUI{1};
    end

    nameInGUI=strtrim(nameInGUI);
    nameInGUI(isspace(nameInGUI))='_'; % Replace spaces with underscores

    if ~isvarname(nameInGUI)
        beep;
        disp('Try again, invalid argument name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(nameInGUI)>namelengthmax-4 % Minus 3 because of the underscore and hard-coded and level identifiers in the name.
        beep;
        disp(['Try again, argument name too long! Must be less than or equal to ' num2str(namelengthmax-4) ' characters, but is currently ' num2str(length(nameInGUI)) ' characters!']);
        continue;
    end

    % 2. Check if this argument name already exists in the list.
    if ismember(nameInGUI,guiNames)
        disp('This variable already exists! No argument added, try again.');
        continue;
    end

    nameInGUIOK=1;
end

%% Prompt for the default name of the argument in the code.
while ~defaultNameInCodeOK
    % 3. Ask for a default name in the code to use when adding a variable to a function.
%     input2=inputdlg('Enter default argument name in code (leave blank to not provide default)','Default name',[1 35],{genvarname(nameInGUI)});
    input2=input(['Enter default argument name in code (leave blank to use ''' genvarname(nameInGUI) ''': ']); % Avoids the inputdlg which has been SUPER buggy for me.
    if isempty(input2)
        input2=genvarname(nameInGUI);
    end

    if isempty(input2)
        disp('Process cancelled, no argument added');
        return;
    end
    if iscell(input2) && isempty(input2{1})
        defaultName='';
    else
        if iscell(input2)
            defaultName=input2{1};
        else
            defaultName=input2;
        end
    end

    if ~isvarname(defaultName)
        beep;
        disp('Improper argument name! Must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(defaultName)>namelengthmax-4
        beep;
        disp(['Argument name too long! Must be less than or equal to ' num2str(namelengthmax-4) ' characters, but is currently ' num2str(length(defaultName)) ' characters!']);
        continue;
    end

    defaultNameInCodeOK=1;
end

%% 4. Ask whether the variable will be hard-coded
input3=questdlg('Is this a hard-coded variable?','Hard-coded variable?','Yes','No','No');
if isempty(input3)
    disp('Process cancelled, no argument added');
    return;
end

switch input3
    case 'Yes'
        isHC=1;        
    case 'No'
        isHC=0;
end

%% 5. Ask what level the variable will be stored at (Project, Subject, or Trial)
input4=questdlg({'Project, Subject, or Trial level variable?','This can be changed later.'},'Variable Level','Project','Subject','Trial','Trial');
if isempty(input4)
    disp('Process cancelled, no argument added');
    return;
end

switch input4
    case 'Project'
        level='P';
    case 'Subject'
        level='S';
    case 'Trial'
        level='T';
end

% 6. Add this variable to the GUI
if exist('VariableNamesList','var')==1
    rowNum=length(VariableNamesList.GUINames)+1;
else
    rowNum=1;
end

selSplit=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(selSplit,' ');
splitName=selSplit(1:spaceIdx-1);
splitCode=selSplit(spaceIdx+2:end-1);

if exist('VariableNamesList','var')~=1 || ~isfield(VariableNamesList,'SplitCodes') || length(VariableNamesList.SplitCodes)<rowNum
    VariableNamesList.SplitCodes{rowNum}={splitCode};
    VariableNamesList.SplitNames{rowNum}={splitName};
else
    VariableNamesList.SplitNames{rowNum}=[VariableNamesList.SplitNames(rowNum); {splitName}];
    VariableNamesList.SplitCodes{rowNum}=[VariableNamesList.SplitCodes(rowNum); {splitCode}];
end

VariableNamesList.GUINames{rowNum,1}=nameInGUI;
VariableNamesList.SaveNames{rowNum,1}=defaultName;
VariableNamesList.Descriptions{rowNum,1}={'Enter Arg Description Here'};
VariableNamesList.Level{rowNum,1}=level;
VariableNamesList.IsHardCoded{rowNum,1}=isHC;

% 7. Now, add this variable to the VariablesMainList
if isHC==1
    % Create and store here the name of the .m file.
    folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
    if exist(folderName,'dir')~=7
        mkdir(folderName);
    end
%     splitName=handles.Process.splitsUITree.SelectedNodes.Text;
    splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;
    fileName=[folderName slash defaultName '_' splitCode '.m'];
    
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'hardCodedVar_Template.m'];
    if exist(fileName,'file')~=2
        createFileFromTemplate(templatePath,fileName,[defaultName '_' splitCode]);
    end
    edit(fileName);
end

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));
delete(handles.Process.varsListbox.Children);
for i=1:length(VariableNamesList.GUINames)
    varName=VariableNamesList.GUINames{sortIdx(i)};
    varNode=uitreenode(handles.Process.varsListbox,'Text',varName);
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
        if i==1 && j==1
            handles.Process.varsListbox.SelectedNodes=a;
        end
    end

    if isequal(varName,nameInGUI)
        handles.Process.varsListbox.SelectedNodes=varNode;
    end

end

% handles.Process.varsListbox.Items=VariableNamesList.GUINames(idx);
% handles.Process.varsListbox.Value=nameInGUI;
varsListboxSelectionChanged(fig);
% handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{rowNum};

save(projectSettingsMATPath,'VariableNamesList','-append');