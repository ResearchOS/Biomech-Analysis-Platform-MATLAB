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

h=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
dataType=lower(h.Value); % Always capital letters
alphaNumericIdx=isstrprop(dataType,'alpha') | isstrprop(dataType,'digit');
dataType=dataType(alphaNumericIdx);

importFcnName=[dataType 'Import' methodNumber '_' projectName '.m'];

h=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');
if isequal(h.Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.   
    everythingPath=getappdata(fig,'everythingPath');
    templatePath=[everythingPath 'App Creation & Component Management' everythingPath(end) 'Project-Independent Templates' everythingPath(end) 'importFcnTemplate.m'];
    copyfile(templatePath,[importPath importFcnName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath importFcnName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [' lower(dataType) 'Struct]=' importFcnName(1:end-2) '()'];
    fid=fopen([importPath importFcnName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    h.Text='Open importFcn';
end

edit([importPath importFcnName]); % Always open the file.