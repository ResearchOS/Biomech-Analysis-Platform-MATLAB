function []=runLoad(fig)

%% PURPOSE: LOAD OR OFFLOAD EACH INDIVIDUAL GROUP'S DATA (INPUTS & OUTPUTS OF ALL FUNCTIONS IN THAT GROUP)
% Inputs:
% fig: The figure variable (handle)

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fig=ancestor(fig,'figure','toplevel'); % Just in case the input fig isn't the top level.
projectStruct=evalin('base','projectStruct;'); % Bring the entire projectStruct into this workspace.

% cd into the directory with this project's import, then back out.
currDir=pwd;
cd([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash 'Specify Trials']);
inclStruct=specifyTrials_Import;
cd(currDir);

logPath=getappdata(fig,'logsheetPath');
splitPath=strsplit(logPath,'.');
ext=splitPath{end};
logVar=load([logPath(1:end-length(ext)) 'mat']);
fldName=fieldnames(logVar);
assert(length(fldName)==1);
logVar=logVar.(fldName{1});
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);

% Read the text file containing whether to load or offload the group data.
text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,getappdata(fig,'projectName'));

% Read the group names groupText file
groupText=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
[groupNames,lineNums]=getGroupNames(groupText);

if isequal(groupNames{1},'Create Group Name') && length(groupNames)==1
    return; % Check that some group name(s) exist
end

% Get the method number & letter for each function name in each group. Also get whether to load or offload it
for i=1:length(groupNames)
    
    % Get the group name as valid field name
    idx=isstrprop(groupNames{i},'alpha') | isstrprop(groupNames{i},'digit');
    groupNameField=groupNames{i}(idx);
    
    assert(isvarname(groupNameField)); % Check that it's a valid variable name.
    
    % Get whether to load or offload the group's data, or do nothing.
    action=projectNamesInfo.(['DataPanel' groupNameField]);
    
    allGroups.(groupNameField).Action=action; % Store the action to take (Load, Offload, or None)
    
    % Iterate over all function names in that group
    for j=lineNums(i)+1:length(groupText)
        currLine=groupText{j};
        
        if isempty(currLine)
            break;
        end
        
        colonSplit=strsplit(currLine,':');
        beforeColon=strsplit(colonSplit{1},' ');
        fcnName=beforeColon{1};
        fcnLetter=beforeColon{2}(isletter(beforeColon{2}));
        fcnNum=beforeColon{2}(~isletter(beforeColon{2}));
        
        allGroups.(groupNameField).FunctionNames{i}=fcnName;
        allGroups.(groupNameField).FunctionLetter{i}=fcnLetter;
        allGroups.(groupNameField).FunctionNumber{i}=fcnNum;
        allGroups.(groupNameField).ProcessFcnNames{i}=[fcnName '_Process' fcnNum];
        allGroups.(groupNameField).ProcessArgsNames{i}=[fcnName '_Process' fcnNum fcnLetter];
        
    end
    
end

%% Get all the arguments and aggregate them into one long list to load, and one to offload.
groupNamesField=fieldnames(allGroups);
subNames=fieldnames(allTrialNames);
loadList={''};
loadCount=0;
offloadList={''};
offloadCount=0;
for i=1:length(groupNamesField)
    groupNameField=groupNamesField{i};
    
    currGroup=allGroups.(groupNameField);
    currAction=currGroup.Action;
    
    if isequal(currAction,'None')
        continue; % Don't process the groups that don't need loading or offloading
    end        
    
    varNum=0; % Reset the number of variables for each function group

    for j=1:length(currGroup.ProcessFcnNames) % Iterate through all functions in this group
        fcnName=currGroup.ProcessFcnNames{i};
        argName=currGroup.ProcessArgsNames{i};
        argLetter=currGroup.FunctionLetter{i};
        
        
        argFilePath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash argName '.m'];
        
        % Call the processing function to determine what processing level to call it and the args at.
        level=feval(fcnName); % nargin=0
%         level=level{1}; % Convert from cell to char
        
        if contains(level,'P') && ~contains(level,'S') && ~contains(level,'T')
            % Project level call
            callLevel='P';
        elseif contains(level,'S') && ~contains(level,'T')
            % Subject level call
            callLevel='S';
        elseif contains(level,'T')
            % Trial level call
            callLevel='T';
        end
        
        %% At each level:
        % Call the processing function, returns the path for all output vars        
        % Call the args function, return the path for all input vars
        % Having the first input argument be 1 indicates to the processing function to return only the variable paths, not the data.
        if callLevel=='P'
            varNum=varNum+1;
            varPaths{varNum}=readArgsFcn(argFilePath); % Read the arguments function
            varNum=varNum+1;
            varPaths{varNum}=feval(fcnName,1,argLetter); % Call the processing function 
            continue; % Go to the next function.
        end
        
        for sub=1:length(subNames)
            subName=subNames{sub};
            if callLevel=='S'
                varNum=varNum+1;
                varPaths{varNum}=readArgsFcn(argFilePath,subName); % Read the arguments function
                varNum=varNum+1;
                varPaths{varNum}=feval(fcnName,1,argLetter,subName); % Call the processing function 
                continue;
            end
            
            trialNames=allTrialNames.(subName);
            for trialNum=1:length(trialNames) % If I have gotten here, it must be because the callLevel is 'T'
                trialName=trialNames{trialNum};
                varNum=varNum+1;
                varPaths{varNum}=readArgsFcn(argFilePath,subName,trialName); % Read the arguments function
                varNum=varNum+1;
                varPaths{varNum}=feval(fcnName,argLetter,subName,trialName); % Call the processing function            
            end            
            
        end                
        
    end   
    
    % For each group, aggregate them all into one list, instead of a list of lists.
    currGroupList={''}; % Reset the current group list variable.
    for k=1:length(varPaths)        
        if k==1
            currGroupList=varPaths{k};
        else
            currGroupList=[currGroupList; varPaths{k}];
        end        
    end
    
    if isequal(currAction,'Load')
        loadCount=loadCount+1;
        if loadCount==1
            loadList=currGroupList;
        else
            loadList=[loadList; currGroupList];
        end
    elseif isequal(currAction,'Offload')
        offloadCount=offloadCount+1;
        if offloadCount==1
            offloadList=currGroupList;
        else
            offloadList=[offloadList; currGroupList];
        end
    end
    
end

%% Offload all data
for i=1:length(offloadList)
    
    if isempty(offloadList{1}) && length(offloadList)==1
        break;
    end
    
    % Need the struct field above the one to be removed.
    currPath=offloadList{i};
    allFields=strsplit(currPath,'.');
    for j=1:length(allFields)-1 % Reconstitute the previous field name
        if j==1
            prevField=allFields{j};
        else
            prevField=[prevField '.' allFields{j}];
        end        
    end
    
    % Offload the data from the projectStruct in the base workspace.
    assignin('base','upperField',prevField);
    assignin('base','structPath',currPath);
    assignin('base','rmFieldName',allFields{j});
    evalin('base','upperField=rmfield(structPath,rmFieldName);');
    
end

%% Load all data
for i=1:length(loadList)
    
    if isempty(loadList{1}) && length(loadList)==1
        break;
    end
    
    currPath=loadList{i};
    % Convert the project path to a file path.
    allFields=strsplit(currPath,'.');
    filePath=[getappdata(fig,'dataPath') 'MAT Data Files'];
    for j=2:length(allFields)        
        filePath=[filePath slash allFields{j}];        
    end
    
    filePath=[filePath '.mat'];
    
    % Check if the file exists.
    if exist(filePath,'file')~=2
        warning(['Non-Existent: ' filePath]);
    end
    
    % Load the data
    currData=load(filePath);
    dataName=fieldnames(currData);
    assert(length(dataName)==1);
    currData=currData.(dataName);
    
    % Store the data to the projectStruct in the base workspace.
    assignin('base','structPath',currPath);
    assignin('base','loadData',currData);
    evalin('base','structPath=loadData;');
    
end