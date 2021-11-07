function []=openSpecifyVarsButtonPushed(src, projectName)

%% PURPOSE: SPECIFY WHICH VARIABLES TO LOAD WHEN THE SPECIFYVARS BUTTON ON THE IMPORT TAB IS PUSHED

fig=ancestor(src,'figure','toplevel');
codePath=getappdata(fig,'codePath');
if isempty(codePath)
    warning('Need to enter the code path!');
    return;
end
if exist(codePath,'dir')~=7
    warning(['Fix the code path: ' codePath]);
    return;
end

% Check if Mac or PC
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

importPath=[codePath projectName '_Import' slash];

if ~isfolder(importPath)
    mkdir(importPath);
end

specifyVarsName=['specifyVars_Import' projectName '.m'];

if isequal(fig.Children.Children(1,1).Children(6,1).Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.    
    copyfile('specifyVars_Template.m',[importPath specifyVarsName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath specifyVarsName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [inclStruct]=' specifyVarsName(1:end-2) '(logsheetPath,projectPath,projectName)'];
    fid=fopen([importPath specifyVarsName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    fig.Children.Children(1,1).Children(6,1).Text=['Open ' specifyVarsName];
end

edit([importPath specifyVarsName]); % Always open the file.