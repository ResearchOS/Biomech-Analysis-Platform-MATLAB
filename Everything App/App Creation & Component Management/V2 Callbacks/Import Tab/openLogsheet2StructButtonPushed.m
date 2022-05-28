function []=openLogsheet2StructButtonPushed(src,event)

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

h=findobj(fig,'Type','uibutton','Tag','OpenLogsheet2StructButton');

if ~isfolder(importPath)
    mkdir(importPath);
end

log2StructName=['Logsheet2Struct_' projectName '.m'];

if isequal(h.Text(1:6),'Create')
    everythingPath=getappdata(fig,'everythingPath');
    templatePath=[everythingPath 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'logsheet2StructTemplate.m'];
    copyfile(templatePath,[importPath log2StructName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath log2StructName]),'\n','split'); % Open the newly created logsheet2Struct file.
    A{1}=['function [logFields]=' log2StructName(1:end-2) '(src)'];
    fid=fopen([importPath log2StructName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    h.Text=['Open Logsheet2Struct_' projectName];
end

edit([importPath log2StructName]); % Always open the file.