function []=writeAllArgsTextFile(txtPath,guiTab,groupName,fcnName,argName,projectName,nameInCode,description)

%% PURPOSE: WRITE TO THE ALLPROJECTS_ALLARGSNAMES.TXT FILE
% Inputs:
% txtPath: The full path to the text file (char)
% guiTab: The tab in the GUI that the args are called from (char)
% groupName: The current processing group (for Process tab only).
% fcnName: The full function name including guiTab, fcnNumber, fcnLetter (char)
% argName: The argument name to write to the file (char)
% projectName: The current project name (char)
% nameInCode: (optional)

fcnNameSplit=strsplit(fcnName,'_');
underscoreIdx=strfind(fcnName,'_');
if ~isequal(fcnNameSplit{1},'Unassigned')
    fcnNameOnly=fcnName(1:underscoreIdx(end));

    methodNumIdx=isstrprop(fcnNameSplit{end},'digit');
    suffix=fcnNameSplit{end}; % guiTab, methodNum, & methodLetter
    methodNum=suffix(methodNumIdx); % methodNum
    methodNumIdx=find(methodNumIdx==1,1,'first');
    guiTab=fcnNameSplit{end}(1:methodNumIdx-1); % Which tab the args is being called from.
    suffixAfterGuiTab=fcnNameSplit{end}(methodNumIdx:end);
    methodLetter=suffixAfterGuiTab(isstrprop(suffixAfterGuiTab,'alpha'));
else
    fcnNameOnly='Unassigned';
    methodNum='1';
    methodLetter='A';
%     guiTab=fcnNameSplit{2};
end

projectFound=0;
fcnFound=0;
groupFound=0;

if exist(txtPath,'file')==2
    text=regexp(fileread(txtPath),'\n','split');
    if size(text,1)<size(text,2)
        text=text'; % Ensure that it is a column vector
    end
else
    text{1,1}=['Project Name: ' projectName];
    text{2,1}=['Group Name: ' fcnName];
    text{3,1}=['Function Name: ' fcnName];
    text{4,1}=[guiTab ': ' argName ':'];
    text{5,1}='';
    fid=fopen(txtPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
    return;
end

if ~isempty(text{end})
    text=[text; {''}]; % Ensure that there is an empty space at the end because the algorithm needs it.
end

insertType={};
st=dbstack;
caller=st(2).name;

for i=1:length(text)

    currLine=text{i};

    if projectFound==0 && length(currLine)>=length(['Project Name: ' projectName]) && isequal(currLine(1:length(['Project Name: ' projectName])),['Project Name: ' projectName])
        projectFound=1;
        continue;
    end

    if projectFound==0
        insertType={'Project'; 'Group'; 'Function'; 'Arg'};
        continue; % Skip other projects
    end

    if length(text{i})>=length('Project Name:') && isequal(text{i}(1:length('Project Name:')),'Project Name:') % Another project was found after this one. Current project has ended.
        currLineNum=i;
        insertType={'Group'; 'Function'; 'Arg'};
        break; % Current project has ended and the group was not found. Insert new group.
    end

    if length(currLine)>=length(['Group Name: ' groupName]) && isequal(currLine(1:length(['Group Name: ' groupName])),['Group Name: ' groupName])
        groupFound=1;
        continue;
    end

    if groupFound==0
        insertType={'Group'; 'Function'; 'Arg'};
        continue; % Skip other groups in project
    end

    if length(text{i})>=length('Group Name:') && isequal(text{i}(1:length('Group Name:')),'Group Name:') % Another project was found after this one. Current project has ended.
        currLineNum=i;
        insertType={'Function'; 'Arg'};
        break; % Current group has ended and the function was not found. Insert new function
    end

    if length(currLine)>=length(['Function Name: ' fcnName]) && isequal(currLine(1:length(['Function Name: ' fcnName])),['Function Name: ' fcnName])
        fcnFound=1;
        continue;
    end    

    if fcnFound==0
        continue; % Skip other functions in group
    end

    if isempty(currLine)
        currLineNum=i;
        insertType={'Arg'};
        break; % The current function in the current group in the current project has ended. Insert new argument and/or function here.
    end

    currLineSplit=strsplit(currLine,':'); % Check the value of each line
    % Format:
    % guiTab: argName: 0 nameInCode, 1 nameInCode: Description

    if ~(isequal(currLineSplit{1},guiTab) && isequal(strtrim(currLineSplit{2}),argName))
        continue; % This argument name does not match any existing.
    end    
    
    if ~(exist('nameInCode','var') && exist('description','var'))
        continue;
    end

    % Here, this argument name matches an existing argument name. Can modify its metadata.
%     insertType='None'; % Indicate that a line was modified, and therefore nothing is to be inserted.
%     if isequal(caller,'addArgsToFcnButtonPushed') % Do 
    insertType={'None'};
    currLine=[guiTab ': ' argName ': ' nameInCode ': ' description];
    text{i}=currLine;
    break;
    
end

% if projectFound==0
%     % insert new project
%     currLineNum=i;
%     
% end

% If only modification was done here, no insertions, then save off the file and exit here.
if isequal(insertType,{'None'})
    fid=fopen(txtPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
    return;
end

if i==length(text)
    newLineNum=length(text);
    currLineNum=i;
else
    newLineNum=currLineNum-1;
end

newText=text(1:newLineNum);

if ismember('Project',insertType) % Create a new project.
    newLineNum=newLineNum+1;
    newText{newLineNum}=['Project Name: ' projectName];
end

if ismember('Group',insertType) % Create a new group
    newLineNum=newLineNum+1;
    newText{newLineNum}=['Group Name: ' groupName];
end

if ismember('Function',insertType)
    newLineNum=newLineNum+1;
    newText{newLineNum}=['Function Name: ' fcnName];
end

if ismember('Arg',insertType)
    if any(ismember({'Function','Group','Project'},insertType))
        newLineNum=newLineNum+1; % Increment line number if added project, group, or function. Otherwise, line number ok.
    end
    newText{newLineNum}=[guiTab ': ' argName ':'];
    if exist('nameInCode','var') && exist('description','var')
        newText{newLineNum}=[newText{newLineNum} ' ' nameInCode ': ' description];
    end
end

newLineNum=newLineNum+1;
% newText{newLineNum+1}='';
newText=[newText; text(currLineNum:end)];

if ~isempty(newText{end})
    newText=[newText; {''}]; % Ensure that there is always an empty line at the end because the algorithm needs it.
end

fid=fopen(txtPath,'w');
fprintf(fid,'%s\n',newText{1:end-1});
fprintf(fid,'%s',newText{end});
fclose(fid);


