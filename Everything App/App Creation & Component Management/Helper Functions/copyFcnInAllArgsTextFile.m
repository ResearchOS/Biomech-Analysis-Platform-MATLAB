function [bool]=copyFcnInAllArgsTextFile(txtPath,guiTab,groupName,fcnNameNew,fcnNameOld,projectName)

%% PURPOSE: COPY A FUNCTION'S ARGUMENTS OVER FROM ONE LETTER TO THE NEXT WHEN CREATING A NEW LETTER.
% Inputs:
% txtPath: Path to the allProjectArgsTxtPath (char)
% guiTab: The current tab in the gui that the args are called from (char)
% groupName: The current group (only used in Process tab) (char)
% fcnNameNew: The new function name in the same group to copy things over to (char)
% fcnNameOld: The existing function name to copy over (char)
% projectName: The current project name (char)

projectFound=0;
fcnFound=0;
groupFound=0;

if exist(txtPath,'file')==2
    text=regexp(fileread(txtPath),'\n','split');
else
    warning(['No args yet, no need for a new version!']);
    bool=0; % Indicate not to proceed with processing outside of this function.
    return;
end

if size(text,1)<size(text,2)
    text=text'; % Ensure that it is a column vector
end

if ~isempty(text{end})
    text=[text; {''}]; % Ensure that there is an empty space at the end because the algorithm needs it.
end

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

    if length(currLine)>=length(['Function Name: ' fcnNameOld]) && isequal(currLine(1:length(['Function Name: ' fcnNameOld])),['Function Name: ' fcnNameOld])
        fcnFound=1;
        firstArgLine=i+1;
        continue;
    end    

    if fcnFound==0
        continue; % Skip other functions in group
    end

    % Function has been found. Need to grab all lines until an empty row.

    if isempty(currLine)
        lastArgLine=i-1;
        break; % The current function in the current group in the current project has ended. Insert new argument and/or function here.
    end
    
end

bool=1; % Indicate that it's ok to continue processing outside of this function

newText=text(1:lastArgLine); % Copy over everything through the end of this function
newText(lastArgLine+1)={''}; % Include a dividing empty line
newText(lastArgLine+2)={['Function Name: ' fcnNameNew]}; % Insert the function name
newText=[newText; text(firstArgLine:lastArgLine)]; % Append the contents of the new function
newText=[newText; text(lastArgLine:end)]; % Append the rest of the txt file

fid=fopen(txtPath,'w');
fprintf(fid,'%s\n',newText{1:end-1});
fprintf(fid,'%s',newText{end});
fclose(fid);