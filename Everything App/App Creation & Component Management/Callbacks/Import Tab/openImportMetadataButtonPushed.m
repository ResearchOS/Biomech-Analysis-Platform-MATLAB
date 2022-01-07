function []=openImportMetadataButtonPushed(src)

%% PURPOSE: ON IMPORT TAB, IF OPEN IMPORT METADATA BUTTON PUSHED, OPEN THE IMPORT SETTINGS FILE FOR THE DATA TYPE.

fig=ancestor(src,'figure','toplevel');
projectName=getappdata(fig,'projectName');
codePath=getappdata(fig,'codePath');
if isempty(codePath)
    warning('Need to enter the code path!');
    beep;
    return;
end
if exist(codePath,'dir')~=7
    warning(['Fix the code path: ' codePath]);
    beep;
    return;
end

% Check if Mac or PC
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

importPath=[codePath 'Import_' projectName slash];

% Get the letter of the method.
hMethod=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
method=hMethod.Value; % Always capital letters (number & letter both)

if ~isfolder(importPath)
    mkdir(importPath);
end

hDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
dataType=lower(hDropDown.Value); % Always capital letters
alphaNumericIdx=isstrprop(dataType,'alpha') | isstrprop(dataType,'digit');
dataType=dataType(alphaNumericIdx);

importArgsName=[dataType '_Import' method '.m'];

hButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');

if isequal(hButton.Text(1:6),'Create') && exist([importPath 'Arguments' slash importArgsName],'file')==2
    error('Button says ''Create'' but the file already exists');
end

if isequal(hButton.Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.   
    everythingPath=getappdata(fig,'everythingPath');
    templatePath=[everythingPath 'App Creation & Component Management' everythingPath(end) 'Project-Independent Templates' everythingPath(end) 'Import_argsTemplate.m'];
    copyfile(templatePath,[importPath 'Arguments' slash importArgsName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath 'Arguments' slash importArgsName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [' lower(dataType) 'Helper]=' importArgsName(1:end-2) '()'];
    fid=fopen([importPath 'Arguments' slash importArgsName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    hButton.Text=['Open Import Args ' hDropDown.Value];
end

edit([importPath 'Arguments' slash importArgsName]); % Always open the file.