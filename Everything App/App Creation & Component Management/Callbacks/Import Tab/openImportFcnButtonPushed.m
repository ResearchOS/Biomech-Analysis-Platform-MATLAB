function []=openImportFcnButtonPushed(src)

fig=ancestor(src,'figure','toplevel');
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

projectName=getappdata(fig,'projectName');

importPath=[codePath 'Import_' projectName slash];

% Get the letter of the method.
hMethod=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
methodNumber=hMethod.Value(~isletter(hMethod.Value)); % Always capital letters

if ~isfolder(importPath)
    mkdir(importPath);
end

hDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
dataType=lower(hDropDown.Value); % Always capital letters
alphaNumericIdx=isstrprop(dataType,'alpha') | isstrprop(dataType,'digit');
dataType=dataType(alphaNumericIdx);

importFcnName=[dataType '_Import' methodNumber '.m'];

hButton=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');

if isequal(hButton.Text(1:6),'Create') && ...
        (exist([importPath 'User-Created Functions' slash importFcnName],'file')==2 || ... % User-created
        exist([importPath 'Existing Functions' slash importFcnName],'file')==2 || ... % Existing from library
        exist([getappdata(fig,'everythingPath') 'm File Library' slash 'Import' slash hDropDown.Value slash importFcnName],'file')==2) % In library but not copied over yet.
    error('Button says ''Create'' but the file already exists');
end


if isequal(hButton.Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.
    everythingPath=getappdata(fig,'everythingPath');
    templatePath=[everythingPath 'App Creation & Component Management' everythingPath(end) 'Project-Independent Templates' everythingPath(end) 'Import_fcnTemplate.m'];
    copyfile(templatePath,[importPath 'User-Created Functions' slash importFcnName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath 'User-Created Functions' slash importFcnName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [' lower(dataType) 'Struct]=' importFcnName(1:end-2) '()'];
    fid=fopen([importPath 'User-Created Functions' slash importFcnName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);
    hButton.Text=['Open Import Fcn ' hDropDown.Value];
    openPath=[importPath 'User-Created Functions' slash importFcnName];
else
    
    if exist([importPath 'Existing Functions'],'dir')~=7
        mkdir([importPath 'Existing Functions']);
    end
    
    % If the file exists in the library but not in the 'Existing Functions' folder, copy it from the library to the 'Existing Functions' folder
    if exist([getappdata(fig,'everythingPath') 'm File Library' slash 'Import' slash hDropDown.Value slash importFcnName],'file')==2 && ...
            exist([importPath 'Existing Functions' slash importFcnName],'file')~=2
        
        copyfile([getappdata(fig,'everythingPath') 'm File Library' slash 'Import' slash hDropDown.Value slash importFcnName],...
            [importPath 'Existing Functions' slash importFcnName]);
        
    end
    
    % If it exists in the 'Existing Functions' folder already, just open that file.
    if exist([importPath 'Existing Functions' slash importFcnName],'file')==2
        openPath=[importPath 'Existing Functions' slash importFcnName];
    elseif exist([importPath 'User-Created Functions' slash importFcnName],'file')==2
        openPath=[importPath 'User-Created Functions' slash importFcnName];
    else
        error('Function missing when it should not be');
    end
    
end

edit(openPath); % Always open the file.