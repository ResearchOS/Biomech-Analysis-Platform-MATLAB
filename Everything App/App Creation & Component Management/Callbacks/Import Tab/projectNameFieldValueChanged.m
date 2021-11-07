function []=projectNameFieldValueChanged(src)

%% PURPOSE: STORE THE PROJECT NAME TO THE APP DATA, AND TO THE TEXT FILE IN THE DOCUMENTS FOLDER.
% After the project is specified, there will always be a 'allProjects_ProjectNamesPaths.txt' file.

projectName=src.Value;

fig=ancestor(src,'figure','toplevel');
if isempty(projectName)
    src.Value=getappdata(fig,'projectName');
    if isempty(src.Value) % Because there was no prior projectName stored
        src.Value='Project Name';
    end
    return;
end

setappdata(fig,'projectName',projectName); % Store the project name to the app data.
fileName=getappdata(fig,'allProjectsTxtPath'); % Get the 'allProjects_ProjectNamesPaths.txt' path.

h=findall(fig.Children.Children(1,1));
for i=1:length(h)
    if i~=1 && i~=13 && i~=17 % Ignore the project name textbox and label.
        h(i).Visible='on';
    end
end

% Check if this project name is already part of the drop down list (e.g. it's already an existing project, at least in name)
% If so, just change the drop down entry and update the metadata/edit fields accordingly.
dropDownList=fig.Children.Children(1,1).Children(5,1).Items;
existingProject=0; % Initialize that this project does not exist yet.
for i=1:length(dropDownList)
    if isequal(dropDownList{i},projectName) % If the new project name and one of the drop down items matches exactly
        fig.Children.Children(1,1).Children(5,1).Value=projectName;
        existingProject=1; % Indicates that this project was pre-existing.
        break;
    end
end

% If the project was pre-existing
if existingProject==1
    A=readAllProjects(); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
    projectNamePaths=isolateProjectNamesPaths(A,projectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data, & update the displays
    if isfield(projectNamePaths,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNamePaths.LogsheetPath);
        fig.Children.Children(1,1).Children(11,1).Value=getappdata(fig,'logsheetPath');
    else% Set to default
        setappdata(fig,'logsheetPath','');
        fig.Children.Children(1,1).Children(11,1).Value='Set Logsheet Path';
    end
    if isfield(projectNamePaths,'DataPath')
        setappdata(fig,'dataPath',projectNamePaths.DataPath);
        fig.Children.Children(1,1).Children(10,1).Value=getappdata(fig,'dataPath');
    else
        setappdata(fig,'dataPath','');
        fig.Children.Children(1,1).Children(10,1).Value='Data Path (contains ''Subject Data'' folder)';
    end
    if isfield(projectNamePaths,'CodePath')
        setappdata(fig,'codePath',projectNamePaths.CodePath);
        fig.Children.Children(1,1).Children(9,1).Value=getappdata(fig,'codePath');
    else
        setappdata(fig,'codePath','');
        fig.Children.Children(1,1).Children(9,1).Value='Path to Project Processing Code Folder';
    end
    if isfield(projectNamePaths,'RootSavePlotPath')
        setappdata(fig,'rootSavePlotPath',projectNamePaths.RootSavePlotPath);
    else
        setappdata(fig,'rootSavePlotPath','');
    end
    saveFile=0;
elseif existingProject==0
    % If not already existing, check if the allProjects file exists and/or make a new entry in the 'allProjects_ProjectNamesPaths.txt' file and save it.
    if exist(fileName,'file')~=2 % File does not exist.
        fid=fopen(fileName,'w'); % Create & open the file
        A{1}=['Project Name: ' projectName];
        A{2}='';
        A{3}=['Most Recent Project Name: ' projectName];
        fprintf(fid,'%s\n',A{1:end-1});
        fprintf(fid,'%s',A{end});
        fclose(fid); % Close the file
        saveFile=0;
    else % If file already exists, put new project at the end
        saveFile=1;
        A=readAllProjects();
        mostRecent=A(end-1:end); % Isolate last two lines
        A(end)={['Project Name: ' projectName]}; % Replace last line with project name
        A(length(A)+1:length(A)+2)=mostRecent; % Add two more lines
    end
    allProjectsList=getAllProjectNames(A);
    
    % Update the drop down list, and put the new project name as the current value.
    fig.Children.Children(1,1).Children(5,1).Items=allProjectsList;
    fig.Children.Children(1,1).Children(5,1).Value=projectName;
    
    % Set the other fields to their default values
    setappdata(fig,'logsheetPath','');
    fig.Children.Children(1,1).Children(11,1).Value='Set Logsheet Path';
    setappdata(fig,'dataPath','');
    fig.Children.Children(1,1).Children(10,1).Value='Data Path (contains ''Subject Data'' folder)';
    setappdata(fig,'codePath','');
    fig.Children.Children(1,1).Children(9,1).Value='Path to Project Processing Code Folder';
    setappdata(fig,'rootSavePlotPath','');
end

%% Set the entered project name as the most recently used project at the end of the file.
if saveFile==1
    mostRecentProjPrefix='Most Recent Project Name:';
    for i=length(A):-1:1
        if length(A{i})>length(mostRecentProjPrefix) && isequal(A{i}(1:length(mostRecentProjPrefix)),mostRecentProjPrefix)
            A{i}=[mostRecentProjPrefix ' ' projectName];
            break;
        end
    end
    fid=fopen(fileName,'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);
end