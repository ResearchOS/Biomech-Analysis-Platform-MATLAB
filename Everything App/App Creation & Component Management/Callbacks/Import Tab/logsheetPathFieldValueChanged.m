function []=logsheetPathFieldValueChanged(src)

%% PURPOSE: WHEN THE LOGSHEET PATH FIELD VALUE CHANGES IN THE IMPORT TAB, UPDATE ITS STORED VALUE AND CHANGE THE DISPLAY.

data=src.Value;
if isempty(data)
    return;
end

if exist(data,'file')~=2
    beep;
    warning(['Incorrect logsheet path: ' data]);
    return;
end

fig=ancestor(src,'figure','toplevel');

setappdata(fig,'logsheetPath',data); % Store the logsheet path name to the figure variable.
projectName=getappdata(fig,'projectName'); % Get the current project name.
allProjectsPathTxt=getappdata(fig,'allProjectsTxtPath'); % The full file name of the text file with all projects path names

% The project name should ALWAYS be in this file at this point. If not, it's because it's the first time and they've never entered a project name before.
if exist(allProjectsPathTxt,'file')~=2
    warning('ENTER A PROJECT NAME!');
    return;
end

text=regexp(fileread(allProjectsPathTxt),'\n','split'); % Read in the file, where each line is one cell.

foundProject=0; % Initialize that the project has not been found yet.
projectPrefix='Project Name:';
logsheetPrefix='Logsheet Path:';
logsheetPathExists=0; % Initialize that the logsheet path does not yet exist for this project.
for i=1:length(text)
    
    if length(text{i})>=length(projectPrefix)+length(projectName) && isequal(text{i}(1:length(projectPrefix)),projectPrefix) && isequal(text{i}(length(projectPrefix)+2:end),projectName)
        foundProject=1;
    elseif foundProject==0
        continue;
    end
    
    if isempty(text{i}) % Project section has ended
        lineNum=i;
        break;
    end
    
    % Options:
    % 1. Logsheet Path entry already exists for this project. So just replace the path itself (same line)
    % 2. Logsheet Path entry does not exist for this project. Need to insert a line. Order within each project does not matter.
    
    if length(text{i})>=length(logsheetPrefix) && isequal(text{i}(1:length(logsheetPrefix)),logsheetPrefix) % Case 1
        logsheetPathExists=1;
        text{i}=[logsheetPrefix ' ' data];
    end
    
end

if logsheetPathExists==0
    linesAfter=text(lineNum:length(text)); % Extract everything after the new line.
    text{i}=[logsheetPrefix ' ' data]; % Add the logsheet path to the text.
    text(i+1:i+length(linesAfter))=linesAfter; % Replace the 2nd part of the text.
end
fid=fopen(allProjectsPathTxt,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Read the logsheet, save the .mat file to the same location
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

logPath=getappdata(fig,'logsheetPath');
allParts=strsplit(logPath,slash);
lastPart=strsplit(allParts{length(allParts)},'.');
ext=lastPart{end}; % The file extension used for the logsheet.

if contains(ext,'xls') % .xls or .xlsx
    [~,~,logVar]=xlsread(logPath,1);
else
    
end
matLogPath=[logPath(1:length(logPath)-length(ext)-1) '.mat'];
setappdata(fig,'LogsheetMatPath',matLogPath);
save(matLogPath,'logVar');