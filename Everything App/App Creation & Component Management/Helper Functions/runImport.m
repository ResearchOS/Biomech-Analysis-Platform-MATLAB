function []=runImport(src)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION. EITHER IMPORTS OR LOADS THE DATA FROM RAW DATA FILES.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
assignin('base','gui',fig);

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

if evalin('base','exist(''projectStruct'',''var'') && isstruct(''projectStruct'')')
    projectStruct=evalin('base','projectStruct;');
else
    projectStruct=''; % If the projectStruct does not exist in the base workspace.
end

projectName=getappdata(fig,'projectName');
codePath=getappdata(fig,'codePath');

text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,projectName);

hDataTypesDropDown=handles.Import.dataTypeImportSettingsDropDown;
dataTypes=hDataTypesDropDown.Items; % List of data types

%% Get the method number & letter for each data type
dataTypeText=projectNamesInfo.DataTypes;
dataTypeSplit=strsplit(dataTypeText,', ');
for i=1:length(dataTypeSplit)
    
    dataType=dataTypes{i};
    alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
    dataField=dataType(alphaNumericIdx);
    currSplit=strsplit(dataTypeSplit{i},' ');
    methodLetterNumber=currSplit{end};
    methodLetter.(dataField)=methodLetterNumber(isletter(methodLetterNumber));
    methodNumber.(dataField)=methodLetterNumber(~isletter(methodLetterNumber));
    dataTypeAction.(dataField)=projectNamesInfo.(['DataPanel' dataField]);
    
end

%% INDEPENDENT OF DATA TYPE
% Load the logsheet Excel file (first tab only).
logVar=load(getappdata(fig,'LogsheetMatPath'),'logVar'); % Loads in as 'logVar' variable.
logVar=logVar.logVar; % Convert struct to cell array
% Run specifyTrials
hSpecifyTrialsButton=handles.Import.openGroupSpecifyTrialsButton;
% hSpecifyTrialsButton=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
specTrialsNumIdx=isstrprop(hSpecifyTrialsButton.Text,'digit');
inclStruct=feval(['specifyTrials_Import' hSpecifyTrialsButton.Text(specTrialsNumIdx)]); % Return the inclusion criteria
% Run getValidTrialNames
[allTrialNames,logVar]=getTrialNames(inclStruct,logVar,fig,0);

% Read the text file containing whether to load or offload the group data.
text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,getappdata(fig,'projectName'));

% Read the group names groupText file
groupText=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
[groupNames,lineNums]=getGroupNames(groupText);

loadList={''};
loadCount=0;
offloadList={''};
offloadCount=0;

if ~(isequal(groupNames{1},'Create Group Name') && length(groupNames)==1)
    
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
    
end

%% For each data type present, import the associated data
% Assumes that all data types' folders are all in the same root directory (the data path)

% Get target trial ID column header field
targetTrialIDColHeaderField=handles.Import.targetTrialIDColHeaderField;
targetTrialIDColHeaderName=targetTrialIDColHeaderField.Value;
[~,targetTrialIDColNum]=find(strcmp(logVar(1,:),targetTrialIDColHeaderName));

% Get subject ID column header field
subjIDColHeaderField=handles.Import.subjIDColHeaderField;
subjIDHeaderName=subjIDColHeaderField.Value;
[~,subjIDColNum]=find(strcmp(logVar(1,:),subjIDHeaderName));

% Get Redo checkbox value
redoCheckbox=handles.Import.redoImportCheckbox;
redoVal=redoCheckbox.Value;

% Get data types' trial ID column headers
for i=1:length(dataTypes)
    alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
    dataField=dataTypes{i}(alphaNumericIdx);
    fieldName=['TrialIDColHeader' dataField];
    headerName=projectNamesInfo.(fieldName);
    colNum.(dataField)=find(strcmp(logVar(1,:),headerName));
end

% Iterate through subject names in trialNames variable
subNames=fieldnames(allTrialNames);
for subNum=1:length(subNames)
    
    subName=subNames{subNum};
    trialNames=allTrialNames.(subName);
    
    % Iterate through all trial names in that subject (matches Target Trial ID logsheet column)
    for trialNum=1:length(trialNames)
        
        trialName=trialNames{trialNum};
        
        % Find the logsheet row numbers of that trial name
        subRowIdx=find(strcmp(logVar(:,subjIDColNum),subName));
        rowNums=[]; validCount=0;
        for i=1:length(subRowIdx)
            
            if isequal(strtrim(logVar(subRowIdx(i),targetTrialIDColNum)),{trialName})
                validCount=validCount+1;
                if validCount==1
                    rowNums=subRowIdx(i);
                else
                    rowNums=[rowNums; subRowIdx(i)];
                end
            end
            
        end
        
        for repNum=1:length(rowNums)
            
            rowNum=rowNums(repNum);
            
            % For that logsheet row, check which data types have trial names filled
            % out. Then, read the allProjects text file for which method number &
            % letter is associated with that data type, & execute that function.
            for i=1:length(dataTypes)
                alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
                dataField=dataTypes{i}(alphaNumericIdx);
                dataTypeTrialColNum=colNum.(dataField);
                letter=methodLetter.(dataField);
                assignin('base','methodLetter',letter);
                number=methodNumber.(dataField);
                
                % See if the import function is in the existing functions folder or the user-created folder.
                if exist([codePath 'Import_' projectName slash 'Existing Functions' slash lower(dataField) '_Import' number '.m'],'file')==2
                    existType='Existing Functions';
                elseif exist([codePath 'Import_' projectName slash 'User-Created Functions' slash lower(dataField) '_Import' number '.m'],'file')==2
                    existType='User-Created Functions';
                end
                
                fileName=logVar{rowNum,dataTypeTrialColNum};
                
                fullPathRaw=[getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i} slash fileName]; % Does not contain the file name extension
                fullPathMat=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
                
                % Check if the data types folder exists.
                if exist([getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i}],'dir')~=7
                    error([dataTypes{i} ' Folder Does Not Exist. Should Be At: ' getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i}]);
                end
                
                % Get the file extension of fullPathRaw, because it could be anything.
                listing=dir([getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i}]);
                for k=1:length(listing)
                    if length(listing(k).name)>=length(fileName) && isequal(listing(k).name(1:length(fileName)),fileName)
                        ext=listing(k).name(length(fileName)+1:end); % Get the extension from the first file that meets these criteria. Assumes all files here have same extension
                        break;
                    end
                end
                
                fullPathRaw=[fullPathRaw ext]; % Add the extension to the raw data file path
                
                % Check the checkboxes
                if isequal(dataTypeAction.(dataField),'Load')
                    
                    if exist(fullPathMat,'file')==2 && redoVal==0 % File exists, and redo is not selected.
                        
                        disp(['Now Loading ' subName ' Trial ' trialName ' Data Type ' dataTypes{i} ' ' number letter]);
                        
                        % Load that data
                        if ~isstruct(projectStruct)
                            clear projectStruct;
                        end
                        currData=load(fullPathMat);
                        currData=currData.currData;
                        
                        % Isolate the specific fields of interest.
                        projectStruct.(subName).(trialName)=currData.currData;
                        
                    else % File does not exist, import the data.
                        
                        if exist(fullPathRaw,'file')~=2
                            error(['Missing file: ' fullPathRaw]);
                        end
                        
                        disp(['Now Importing ' subName ' Trial ' trialName ' Data Type ' dataTypes{i} ' & Logsheet Row ' num2str(rowNum)]);
                        
                        currMatDataTypeFolder=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash];
                        if ~isfolder(currMatDataTypeFolder)
                            mkdir(currMatDataTypeFolder);
                        end
                        
                        % Import, store, & save the data.
                        feval([lower(dataField) '_Import' number],fullPathRaw,logVar,rowNum,projectStruct,subName,trialName);
                        
                    end
                    
                elseif isequal(dataTypeAction.(dataField),'Offload')
                    
                    % Remove the unwanted data & associated field.
                    
                    dataFldNames=feval([lower(dataField) '_Import' number]); % The data type field names returned by this function
                    
                    assignin('base','subName',subName);
                    assignin('base','trialName',trialName);
                    assignin('base','importNum',number);
                    assignin('base','importLetter',letter);
                    for kk=1:length(dataFldNames)
                        assignin('base','dataField',dataFldNames{kk});
                        if evalin('base','existField(projectStruct,[''projectStruct.'' subName ''.'' trialName ''.Data.'' dataField ''.Method'' importNum importLetter]);')
                            disp(['Now Removing ' subName ' Trial ' trialName ' Data Structure Field: ' dataFldNames{kk} number letter]);
                            evalin('base','projectStruct.(subName).(trialName).Data.(dataField)=rmfield(projectStruct.(subName).(trialName).Data.(dataField),[''Method'' importNum importLetter]);')
                        end
                    end
                    
                end
                
            end
            
        end
        
    end
    
end