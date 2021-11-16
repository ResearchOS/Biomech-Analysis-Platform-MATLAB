function []=numHeaderRowsFieldValueChanged(src)

%% PURPOSE: STORE THE NUMBER OF HEADER ROWS IN THE LOGSHEET TO A FILE AND TO THE APP DATA

data=src.Value;
if isempty(data)
    return;
end

if data<0
    warning('NUMBER OF HEADER ROWS IN LOGSHEET CANNOT BE NEGATIVE');
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

fig=ancestor(src,'figure','toplevel');

setappdata(fig,'numHeaderRows',data);
projectName=getappdata(fig,'projectName');
allProjectsPathTxt=getappdata(fig,'allProjectsTxtPath');

% The project name should ALWAYS be in this file at this point. If not, it's because it's the first time and they've never entered a project name before.
if exist(allProjectsPathTxt,'file')~=2
    warning('ENTER A PROJECT NAME!');
    return;
end

text=regexp(fileread(allProjectsPathTxt),'\n','split'); % Read in the file, where each line is one cell.

numHeaderRowsPrefix='Number of Header Rows:';
text=addProjInfoToFile(text,projectName,numHeaderRowsPrefix,num2str(data));
fid=fopen(allProjectsPathTxt,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);