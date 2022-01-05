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
        allGroups.(groupNameField).ProcessArgsNames{i}=[fcnName '_Process' fcnLetter];
        
    end
    
end

%% Get all the arguments and aggregate them into one long list to load, and one to offload.
groupNamesField=fieldnames(allGroups);
subNames=fieldnames(allTrialNames);
for i=1:length(groupNamesField)
    groupNameField=groupNamesField{i};
    
    currGroup=allGroups.(groupNameField);
    currAction=currGroup.Action;
    
    if isequal(currAction,'None')
        continue; % Don't process the groups that don't need loading or offloading
    end

    for j=1:length(currGroup.ProcessFcnNames) % Iterate through all functions in this group
        fcnName=currGroup.ProcessFcnNames{i};
        argName=currGroup.ProcessArgsNames{i};
        argLetter=currGroup.FunctionLetter{i};
        
        % Call the processing function to determine what processing level to call it and the args at.
        level=feval(fcnName); % nargin=0
        
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
        % Call the processing function, return the path for all output vars        
        % Call the args function, return the path for all input vars
        % Having the first input argument be 1 indicates to the processing function to return only the variable paths, not the data.
        if callLevel=='P'
            varPath{varNum}=feval(argName,projectStruct); % Call the arguments function
            varPath{varNum}=feval(fcnName,1,argLetter); % Call the processing function 
            continue; % Go to the next function.
        end
        
        for sub=1:length(subNames)
            subName=subNames{sub};
            if callLevel=='S'
                varPath{varNum}=feval(argName,projectStruct,subName); % Call the arguments function
                varPath{varNum}=feval(fcnName,1,argLetter,subName); % Call the processing function 
                continue;
            end
            
            trialNames=allTrialNames.(subName);
            for trialNum=1:length(trialNames) % If I have gotten here, it must be because the callLevel is 'T'
                trialName=trialNames{trialNum};
                varPath{varNum}=feval(argName,projectStruct,subName,trialName); % Call the arguments function
                varPath{varNum}=feval(fcnName,1,argLetter,subName,trialName); % Call the processing function            
            end            
            
        end                
        
    end
    
    
end