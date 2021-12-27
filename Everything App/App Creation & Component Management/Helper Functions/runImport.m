function []=runImport(src)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION

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
inclStruct=feval(['specifyTrials_Import' projectName]); % Return the inclusion criteria
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
        subRowIdx=strcmp(logVar(:,subjIDColNum),subName);
        rowNums=find(strcmp(logVar(subRowIdx,targetTrialIDColNum),trialName))+find(subRowIdx==1,1,'first')-1; % The row numbers with that name.
        
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
                
                fullPath=[getappdata(fig,'dataPath') dataTypes{i} slash subName slash fileName]; % Does not contain the file name extension
                
                % Check the checkboxes
                if isequal(dataTypeAction.(dataField),'Load')
                    
                    % Call the appropriate Import fcn (& the appropriate importMetadata fcn)
                    dataTypeStruct=feval([lower(dataField) 'Import' number '_' getappdata(fig,'projectName')],fullPath);
                    
                    % Store the data type struct
                    returnedTypes=fieldnames(dataTypeStruct);
                    for kk=1:length(returnedTypes) % If multiple data types were included in the one data type function call
                        returnedType=returnedTypes{kk};
                        projectStruct.(subName).(trialName).Data.(returnedType)=dataTypeStruct.(returnedType);
                    end
                    
                elseif isequal(dataTypeAction.(dataField),'Offload')
                    if isfield(projectStruct.(subName).(trialName).Data,dataTypeField)
                        projectStruct.(subName).(trialName).Data=rmfield(projectStruct.(subName).(trialName).Data,dataTypeField);
                    end
                end                
                
            end                                                
            
        end                        
        
    end    
    
end

assignin('base','projectStruct',projectStruct);