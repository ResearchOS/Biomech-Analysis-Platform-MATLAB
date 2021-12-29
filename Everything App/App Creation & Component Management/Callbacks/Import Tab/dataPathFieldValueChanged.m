function []=dataPathFieldValueChanged(src)

%% PURPOSE: STORE THE DATA PATH TO THE FIGURE VARIABLE

data=src.Value;
if isempty(data)
    return;
end

if exist(data,'dir')~=7
    warning(['Incorrect path: ' data]);
    return;
end
if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end
if ~isequal(data(end),slash)
    data=[data slash];
    src.Value=data;
end
fig=ancestor(src,'figure','toplevel');

if ~isempty(getappdata(fig,'dataPath'))
    warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
    rmpath(genpath(getappdata(fig,'dataPath')));
    warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
end

setappdata(fig,'dataPath',data); % Store the data path name to the figure variable.

addpath(genpath(getappdata(fig,'dataPath')));

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
dataPrefix='Data Path:';
dataPathExists=0; % Initialize that the logsheet path does not yet exist for this project.
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
    
    if length(text{i})>=length(dataPrefix) && isequal(text{i}(1:length(dataPrefix)),dataPrefix) % Case 1
        dataPathExists=1;
        text{i}=[dataPrefix ' ' data];
    end
    
end

if dataPathExists==0
    linesAfter=text(lineNum:length(text)); % Extract everything after the new line.
    text{i}=[dataPrefix ' ' data]; % Add the logsheet path to the text.
    text(i+1:i+length(linesAfter))=linesAfter; % Replace the 2nd part of the text.
end
fid=fopen(allProjectsPathTxt,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);