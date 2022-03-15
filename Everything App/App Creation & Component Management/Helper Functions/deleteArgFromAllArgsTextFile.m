function [bool]=deleteArgFromAllArgsTextFile(txtPath,guiTab,groupName,fcnName,argName,projectName)

%% PURPOSE: DELETE AN ARGUMENT FROM THE ALLPROJECTS_ALLARGNAMES.TXT FILE
% Inputs:
% txtPath: The full path to the text file (char)
% guiTab: The tab in the GUI that the args are called from (char)
% groupName: The current processing group (for Process tab only)
% fcnName: The full function name including guiTab, fcnNumber, fcnLetter (char)
% argName: The argument name to remove from the file (char)
% projectName: The current project name (char)

fcnNameSplit=strsplit(fcnName,'_');
underscoreIdx=strfind(fcnName,'_');
if ~isequal(fcnNameSplit{1},'Unassigned')
    fcnNameOnly=fcnName(1:underscoreIdx(end));

    methodNumIdx=isstrprop(fcnNameSplit{end},'digit');
    suffix=fcnNameSplit{end}; % guiTab, methodNum, & methodLetter
    methodNum=suffix(methodNumIdx); % methodNum
    methodNumIdx=find(methodNumIdx==1,1,'first');
    assert(isequal(fcnNameSplit{end}(1:methodNumIdx-1),guiTab));
%     guiTab=; % Which tab the args is being called from.
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

bool=1;

if exist(txtPath,'file')==2
    text=regexp(fileread(txtPath),'\n','split');
else
    bool=0;
    return;
end

if ~isempty(text{1})
    if size(text,1)<size(text,2)
        text=text'; % Ensure that it is a column vector
    end
else
    bool=0;
    return;
end

for i=1:length(text)

    currLine=text{i};

    if projectFound==0 && length(currLine)>=length(['Project Name: ' projectName]) && isequal(currLine(1:length(['Project Name: ' projectName])),['Project Name: ' projectName])
        projectFound=1;
        continue;
    end

    if projectFound==0
%         insertType={'Project'; 'Group'; 'Function'; 'Arg'};
        continue; % Skip other projects
    end

    if length(text{i})>=length('Project Name:') && isequal(text{i}(1:length('Project Name:')),'Project Name:') % Another project was found after this one. Current project has ended.
%         insertType={'Group'; 'Function'; 'Arg'};
        break; % Current project has ended and the group was not found. Insert new group.
    end

    if length(currLine)>=length(['Group Name: ' groupName]) && isequal(currLine(1:length(['Group Name: ' groupName])),['Group Name: ' groupName])
        groupFound=1;
        continue;
    end

    if groupFound==0
%         insertType={'Group'; 'Function'; 'Arg'};
        continue; % Skip other groups in project
    end

    if length(text{i})>=length('Group Name:') && isequal(text{i}(1:length('Group Name:')),'Group Name:') % Another project was found after this one. Current project has ended.
%         insertType={'Function'; 'Arg'};
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
%         insertType={'Arg'};
        break; % The current function in the current group in the current project has ended. Insert new argument and/or function here.
    end

    currLineSplit=strsplit(currLine,':'); % Check the value of each line
    % Format:
    % guiTab: argName: 0 nameInCode, 1 nameInCode: Description

    if ~(isequal(currLineSplit{1},guiTab) && isequal(strtrim(currLineSplit{2}),argName))
        continue; % This argument name does not match any existing.
    end    

    currLineNum=i;

    break;
    
end

if exist('currLineNum','var')~=1
    return; % The arg was never found.
end

newText=text(1:currLineNum-1);
newText=[newText; text(currLineNum+1:end)];

fid=fopen(txtPath,'w');
fprintf(fid,'%s\n',newText{1:end-1});
fprintf(fid,'%s',newText{end});
fclose(fid);