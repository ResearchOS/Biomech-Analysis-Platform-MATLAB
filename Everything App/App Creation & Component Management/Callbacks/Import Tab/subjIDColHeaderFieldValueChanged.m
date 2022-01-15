function []=subjIDColHeaderFieldValueChanged(src)

%% PURPOSE: STORE THE SUBJECT ID COLUMN HEADER IN THE LOGSHEET TO A FILE AND TO THE APP DATA

data=src.Value;
if isempty(data)
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

fig=ancestor(src,'figure','toplevel');

setappdata(fig,'subjectCodenameColumnNum',data);
projectName=getappdata(fig,'projectName');
allProjectsPathTxt=getappdata(fig,'allProjectsTxtPath');

% The project name should ALWAYS be in this file at this point. If not, it's because it's the first time and they've never entered a project name before.
if exist(allProjectsPathTxt,'file')~=2
    warning('ENTER A PROJECT NAME!');
    return;
end

text=regexp(fileread(allProjectsPathTxt),'\n','split'); % Read in the file, where each line is one cell.

prefix='Subject ID Column Header:';
text=addProjInfoToFile(text,projectName,prefix,data);
fid=fopen(allProjectsPathTxt,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Get the column number for the subject codename header in the logsheet
if isempty(getappdata(fig,'logsheetPath'))
    return;
end
logPath=getappdata(fig,'logsheetPath');
dotIdx=strfind(logPath,'.');
logPathMat=[logPath(1:dotIdx(end)) 'mat'];
logVar=load(logPathMat);
fldName=fieldnames(logVar);
assert(length(fldName)==1);
logVar=logVar.(fldName{1});
subjectCodenameHeaderNum=find(ismember(logVar(1,:),data),1,'first');
setappdata(fig,'subjectCodenameColumnNum',subjectCodenameHeaderNum); % The column number for trial names