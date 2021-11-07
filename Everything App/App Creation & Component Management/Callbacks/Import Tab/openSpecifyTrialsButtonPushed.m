function []=openSpecifyTrialsButtonPushed(src, projectName)

%% PURPOSE: ON IMPORT TAB, IF OPEN SPECIFY TRIALS BUTTON PUSHED, OPEN THE SPECIFY TRIALS FUNCTION FOR THAT PROJECT'S IMPORT.

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

specifyTrialsName=['specifyTrials_Import' projectName '.m'];

if isequal(fig.Children.Children(1,1).Children(7,1).Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.    
    copyfile('specifyTrials_Template.m',[importPath specifyTrialsName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath specifyTrialsName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [inclStruct]=' specifyTrialsName(1:end-2) '(logsheetPath,projectPath,projectName)'];
    fid=fopen([importPath specifyTrialsName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    fig.Children.Children(1,1).Children(7,1).Text=['Open ' specifyTrialsName];
end

edit([importPath specifyTrialsName]); % Always open the file.