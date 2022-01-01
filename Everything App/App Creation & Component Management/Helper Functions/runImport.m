function []=runImport(src)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION

tic;
fig=ancestor(src,'figure','toplevel');

text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,getappdata(fig,'projectName'));

hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
dataTypes=hDataTypesDropDown.Items;

% Get the method number & letter for each data type
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

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

projectName=getappdata(fig,'projectName');

%% INDEPENDENT OF DATA TYPE
% Load the logsheet Excel file (first tab only).
logVar=load(getappdata(fig,'LogsheetMatPath'),'logVar'); % Loads in as 'logVar' variable.
logVar=logVar.logVar; % Convert struct to cell array
% Run specifyTrials
inclStruct=feval('specifyTrials_Import'); % Return the inclusion criteria
% Run getValidTrialNames
[allTrialNames,logVar]=getTrialNames(inclStruct,logVar,fig,0);

%% For each data type present, import the associated data
% Assumes that all data types' folders are all in the same root directory (the data path)

% Get target trial ID column header field
targetTrialIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
targetTrialIDColHeaderName=targetTrialIDColHeaderField.Value;
[~,targetTrialIDColNum]=find(strcmp(logVar(1,:),targetTrialIDColHeaderName));

% Get subject ID column header field
subjIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
subjIDHeaderName=subjIDColHeaderField.Value;
[~,subjIDColNum]=find(strcmp(logVar(1,:),subjIDHeaderName));

% Get Redo checkbox value
redoCheckbox=findobj(fig,'Type','uicheckbox','Tag','RedoImportCheckbox');
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
                number=methodNumber.(dataField);
                
                fileName=logVar{rowNum,dataTypeTrialColNum};
                
                fullPathRaw=[getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i} slash fileName]; % Does not contain the file name extension
                fullPathDataMat=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName slash 'Data' slash dataTypes{i} slash 'Method' number letter '.mat'];
                fullPathInfoMat=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName slash 'Info' slash dataTypes{i} slash 'Method' number letter '.mat'];
                
                % Get the file extension of fullPathRaw, because it could be anything.
                listing=dir([getappdata(fig,'dataPath') 'Raw Data Files' slash subName slash dataTypes{i}]);
                for k=1:length(listing)
                    if length(listing(k).name)>=length(fileName) && isequal(listing(k).name(1:length(fileName)),fileName)
                        ext=listing(k).name(length(fileName)+1:end);
                        break;
                    end
                end
                
                fullPathRaw=[fullPathRaw ext]; % Add the extension to the raw data file path
                
                % Check the checkboxes
                if isequal(dataTypeAction.(dataField),'Load')
                    
                    if exist(fullPathDataMat,'file')==2 && exist(fullPathInfoMat,'file')==2 && redoVal==0 % File exists, and redo is not selected.
                        
                        disp(['Now Loading ' subName ' Trial ' trialName ' Data Type ' dataTypes{i}]);
                        
                        % Load that data
                        load(fullPathDataMat,'dataTypeDataStruct');
                        load(fullPathInfoMat,'dataTypeInfoStruct');
                        
                    else % File does not exist, import the data.
                        
                        if exist(fullPathRaw,'file')~=2
                            error(['Missing file: ' fullPathRaw]);
                        end
                        
                        disp(['Now Importing ' subName ' Trial ' trialName ' Data Type ' dataTypes{i} ' & Logsheet Row ' num2str(rowNum)]);
                        
                        % Call the appropriate Import args (letter)
                        [dataTypeArgs]=feval([lower(dataField) '_Import' letter]);
                        
                        % Call the appropriate Import fcn (number)
                        [dataTypeDataStruct,dataTypeInfoStruct]=feval([lower(dataField) '_Import' number],dataTypeArgs,fullPathRaw,logVar,rowNum);
                        
                        % If the data type folder does not exist, create it
                        currMatDataTypeFolder=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName slash 'Data' slash dataTypes{i} slash];
                        currMatDataTypeInfoFolder=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName slash 'Info' slash dataTypes{i} slash];
                        if ~isfolder(currMatDataTypeFolder)
                            mkdir(currMatDataTypeFolder);
                        end
                        if ~isfolder(currMatDataTypeInfoFolder)
                            mkdir(currMatDataTypeInfoFolder);
                        end
                        
                        % Save the data to the file
                        save(fullPathDataMat,'dataTypeDataStruct');
                        
                        % Save the info to the file
                        save(fullPathInfoMat,'dataTypeInfoStruct');
                        
                    end

                    % Store the data type struct to the projectStruct
                    returnedTypes=fieldnames(dataTypeDataStruct);
                    for kk=1:length(returnedTypes) % If multiple data types were included in the one data type function call
                        returnedType=returnedTypes{kk};
                        tempDataStruct=dataTypeDataStruct.(returnedType);
                        tempInfoStruct=dataTypeInfoStruct.(returnedType);
                        assignin('base','subName',subName);
                        assignin('base','trialName',trialName);
                        assignin('base','dataField',returnedType);
                        assignin('base','tempDataStruct',tempDataStruct);
                        assignin('base','tempInfoStruct',tempInfoStruct);
                        evalin('base','projectStruct.(subName).(trialName).Data.(dataField)=tempDataStruct;');
                        evalin('base','projectStruct.(subName).(trialName).Info.(dataField)=tempInfoStruct;');
                    end
                    
                elseif isequal(dataTypeAction.(dataField),'Offload')
                    
                    dataFldNames=feval([lower(dataField) '_Import' number]); % The data type field names returned by this function
                    
                    assignin('base','subName',subName);
                    assignin('base','trialName',trialName);
                    for kk=1:length(dataFldNames)
                        assignin('base','dataField',dataFldNames{kk});
                        if evalin('base','isfield(projectStruct,subName)') && evalin('base','isfield(projectStruct.(subName),(trialName))') ...
                                && evalin('base',"isfield(projectStruct.(subName).(trialName),'Data')")
                            disp(['Now Removing ' subName ' Trial ' trialName ' Data Structure Field: ' dataFldNames{kk}]);
                            evalin('base','projectStruct.(subName).(trialName).Data=rmfield(projectStruct.(subName).(trialName).Data,dataField);')
                        end
                    end

                end                
                
            end                                                
            
        end                        
        
    end    
    
end

toc;