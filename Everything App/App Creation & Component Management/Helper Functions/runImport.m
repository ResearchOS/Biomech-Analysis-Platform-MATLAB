function []=runImport(src)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION. EITHER IMPORTS OR LOADS THE DATA FROM RAW DATA FILES.

%% Initialize projectStruct & figure handles
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
assignin('base','gui',fig);

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% if evalin('base','exist(''projectStruct'',''var'') && isstruct(''projectStruct'')')
%     projectStruct=evalin('base','projectStruct;');
% else
%     projectStruct=''; % If the projectStruct does not exist in the base workspace.
% end

projectName=getappdata(fig,'projectName');
codePath=getappdata(fig,'codePath');
dataPath=getappdata(fig,'dataPath');

text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,projectName);

hDataTypesDropDown=handles.Import.dataTypeImportSettingsDropDown;
dataTypes=hDataTypesDropDown.Items; % List of data types
loadAnyTrial=0; % Initialize that no trial-level data will be loaded.
loadAnySubj=0; % Initialize that no subject-level data will be loaded.
loadAnyProj=0; % Initialize that no project-level data will be loaded.

trialCount=0;
subjCount=0;
projCount=0;

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

    if isequal(dataTypeAction.(dataField),'Load')
        loadAnyTrial=1; % Indicates that trial level MAT files should be loaded.
    end

    % Function names to import each data type
    dataImportFcnNames{i}=[lower(dataField) '_Import' methodNumber.(dataField)];

    % Import function args paths to read through
    dataImportArgsFcnNames{i}=[codePath 'Import_' getappdata(fig,'projectName') slash 'Arguments' slash lower(dataField) '_Import' methodNumber.(dataField) methodLetter.(dataField) '.m'];

    % Read through import function args and get all of the projectStruct
    % paths
    argsPaths.(dataField)=readArgsFcn(dataImportArgsFcnNames{i});

    % Split the argsPaths by project, subject, and trial level.
    for j=1:length(argsPaths.(dataField))
        currPath=argsPaths.(dataField){j};
        currPathSplit=strsplit(currPath,'.');
        if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')
            trialCount=trialCount+1;
            pathsByLevel.(dataField).Trial{trialCount,1}=currPath;
        elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')
            subjCount=subjCount+1;
            pathsByLevel.(dataField).Subject{subjCount,1}=currPath;
        else
            projCount=projCount+1;
            pathsByLevel.(dataField).Project{projCount,1}=currPath;
        end
    end    

    dataFieldNames{i}=dataField; % List of argsPaths field names for importing data.

end

%% Get the method number & letter for each function name in each group. Also get whether to load or offload it
% Read the group names groupText file
groupText=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
[groupNames,lineNums]=getGroupNames(groupText);

if ~(isequal(groupNames{1},'Create Group Name') && length(groupNames)==1)

    for i=1:length(groupNames)

        % Get the group name as valid field name
        idx=isstrprop(groupNames{i},'alpha') | isstrprop(groupNames{i},'digit');
        groupNameField=groupNames{i}(idx);

        assert(isvarname(groupNameField)); % Check that it's a valid variable name.

        % Get whether to load or offload the group's data, or do nothing.
        action=projectNamesInfo.(['DataPanel' groupNameField]);

        allGroups.(groupNameField).Action=action; % Store the action to take (Load, Offload, or None)

        trialCount=0;
        subjCount=0;
        projCount=0;

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
            allGroups.(groupNameField).ProcessArgsNames{i}=[codePath 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash fcnName '_Process' fcnNum fcnLetter '.m'];

            argsPaths.([fcnName fcnNum])=readArgsFcn(allGroups.(groupNameField).ProcessArgsNames{i});

            if ~isequal(action,'Load')
                continue; % If not loading the argsPaths, ignore the below code specifying which level of data to load.
            end

            for k=1:length(argsPaths.([fcnName fcnNum]))

                currPath=argsPaths.([fcnName fcnNum]){k};
                currPathSplit=strsplit(argsPaths.([fcnName fcnNum]){k},'.');
                if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()') % Dynamic trial name
                    loadAnyTrial=1;
                elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()') % Dynamic subject name
                    loadAnySubj=1;
                elseif length(currPathSplit)>=2
                    loadAnyProj=1;
                end

                % Split the argsPaths by project, subject, and trial level.                
                if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')
                    trialCount=trialCount+1;
                    pathsByLevel.([fcnName fcnNum]).Trial{trialCount,1}=currPath;
                elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')
                    subjCount=subjCount+1;
                    pathsByLevel.([fcnName fcnNum]).Subject{subjCount,1}=currPath;
                else
                    projCount=projCount+1;
                    pathsByLevel.([fcnName fcnNum]).Project{projCount,1}=currPath;
                end

            end

        end

    end

end

%% Run the getTrialNames
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

%% Read logsheet for data type-specific metadata for trials of interest
% For each data type present, import the associated data
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

%% Goal:
%%%% Goal for loading/offloading: minimize the number of times opening each .mat file. %%%%

%% Add data types to load/offload list.
% Iterate through subject names in trialNames variable
subNames=fieldnames(allTrialNames);

fullPathProjMat=[dataPath 'MAT Data Files' slash projectName '.mat'];

if loadAnyProj==1 && exist(fullPathProjMat,'file')==2
    % Load project level MAT file, if it exists. Assumes that there are no raw data files at the project level.
    projData=load(fullPathProjMat);
    fldName=fieldnames(projData);
    assert(length(fldName)==1);
    projData=projData.(fldName{1});
    assignin('base','projData');

    %% LOAD/OFFLOAD DATA TYPES' & PROCESSING GROUPS' PROJECT-LEVEL DATA
    fldNames=fieldnames(pathsByLevel);
    for i=1:length(fldNames) % For each data type or processing function
        if isfield(pathsByLevel.(fldNames{i}),'Project') % If thre is project level data to be loaded or offloaded.
            projPaths=pathsByLevel.(fldNames{i}).Project; % Get the path names
            for j=1:length(projPaths) % For each path name, load or offload it.

            end
        end
    end

end

for subNum=1:length(subNames)

    subName=subNames{subNum};
    trialNames=allTrialNames.(subName);

    fullPathSubjMat=[dataPath 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];

    if loadAnySubj==1 && exist(fullPathSubjMat,'file')==2
        % Load subject level MAT file, if it exists.
        subjData=load(fullPathSubjMat);
        subjData=subjData.subjData;
        assignin('base','subjData');

        %% LOAD/OFFLOAD DATA TYPES' & PROCESSING GROUPS' SUBJECT-LEVEL DATA
        fldNames=fieldnames(pathsByLevel);
        for i=1:length(fldNames) % For each data type or processing function
            if isfield(pathsByLevel.(fldNames{i}),'Project') % If thre is project level data to be loaded or offloaded.
                projPaths=pathsByLevel.(fldNames{i}).Project; % Get the path names
                for j=1:length(projPaths) % For each path name, load or offload it.

                end
            end
        end
    end

    % Iterate through all trial names in that subject (matches Target Trial ID logsheet column)
    for trialNum=1:length(trialNames)

        trialName=trialNames{trialNum}; % Trial name as it will be stored in the struct.

        fullPathMat=[dataPath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];

        if loadAnyTrial==1 && exist(fullPathMat,'file')==2
            trialData=load(fullPathMat); % Load the trial's MAT file.
            trialData=trialData.trialData;
            assignin('base','trialData',trialData);
        end

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
            % out. Then, execute the proper import function for those data types
            for i=1:length(dataTypes)
                alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
                dataField=dataTypes{i}(alphaNumericIdx);
                dataTypeTrialColNum=colNum.(dataField);
                letter=methodLetter.(dataField);
                assignin('base','methodLetter',letter);
                number=methodNumber.(dataField);

                % See if the import function is in the existing functions folder or the user-created folder.
%                 if exist([codePath 'Import_' projectName slash 'Existing Functions' slash lower(dataField) '_Import' number '.m'],'file')==2
%                     existType='Existing Functions';
%                 elseif exist([codePath 'Import_' projectName slash 'User-Created Functions' slash lower(dataField) '_Import' number '.m'],'file')==2
%                     existType='User-Created Functions';
%                 end

                fileName=logVar{rowNum,dataTypeTrialColNum};

                fullPathRaw=[dataPath 'Raw Data Files' slash subName slash dataTypes{i} slash fileName]; % Does not contain the file name extension                

                % Check if the data types folder exists.
                if exist([dataPath 'Raw Data Files' slash subName slash dataTypes{i}],'dir')~=7
                    error([dataTypes{i} ' Folder Does Not Exist. Should Be At: ' dataPath 'Raw Data Files' slash subName slash dataTypes{i}]);
                end

                % Get the file extension of fullPathRaw, because it could be anything.
                listing=dir([dataPath 'Raw Data Files' slash subName slash dataTypes{i}]);
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
                        if evalin('base','exist(''projectStruct'',''var'') && ~isstruct(projectStruct)')
                            evalin('base','clear projectStruct');
                        end

                        % Isolate the specific fields of interest.
                        % NOTE: need to check if the field exists so that
                        % eval doesn't throw an inscrutable error here.
                        for k=1:length(argsPaths.(dataField))
                            dotIdx=strfind(argsPaths.(dataField){k},'.');
                            trialPath=argsPaths.(dataField){k}(dotIdx(3)+1:end);
                            newPathSplit=strsplit(argsPaths.(dataField){k},'.');
                            for l=1:length(newPathSplit)
                                if l==1
                                    newPath=newPathSplit{1};
                                else
                                    if l==2 && isequal(newPathSplit{l}([1 end]),'()')
                                        newPath=[newPath '.' subName];
                                    elseif l==3 && isequal(newPathSplit{l}([1 end]),'()')
                                        newPath=[newPath '.' trialName];
                                    else
                                        newPath=[newPath '.' newPathSplit{l}];
                                    end
                                end
                            end
                            evalin('base',[newPath '=trialData.' trialPath ';']);  

                        end

                    else % File does not exist, import the data.

                        if exist(fullPathRaw,'file')~=2
                            error(['Missing file: ' fullPathRaw]);
                        end

                        disp(['Now Importing ' subName ' Trial ' trialName ' Data Type ' dataTypes{i} ' & Logsheet Row ' num2str(rowNum)]);

                        currMatDataTypeFolder=[dataPath 'MAT Data Files' slash subName slash];
                        if exist(currMatDataTypeFolder,'dir')~=7
                            mkdir(currMatDataTypeFolder);
                        end

                        % Import, store, & save the data.
                        if evalin('base','exist(''projectStruct'',''var'')')
                            projectStruct=evalin('base','projectStruct;');
                        else
                            projectStruct='';
                        end
                        feval([lower(dataField) '_Import' number],fullPathRaw,logVar,rowNum,projectStruct,subName,trialName);

                    end

                elseif isequal(dataTypeAction.(dataField),'Offload')

                    % Remove the unwanted data & associated field.

                    disp(['Now Offloading ' subName ' Trial ' trialName ' Data Type ' dataTypes{i} ' ' number letter]);

                    if evalin('base','exist(''projectStruct'',''var'') && ~isstruct(projectStruct)')
                        continue; % Skip this offloading if projectStruct does not exist
                    end

                    for k=1:length(argsPaths.(dataField))
                        dotIdx=strfind(argsPaths.(dataField){k},'.');                        
                        rmdPath=argsPaths.(dataField){k};
                        rmdPath=rmdPath(1:dotIdx(end)-1);
                        rmdPathSplit=strsplit(rmdPath,'.');
                        for l=1:length(rmdPathSplit)
                            if l==1
                                rmdPath=rmdPathSplit{1};
                            else
                                if l==2 && isequal(rmdPathSplit{l}([1 end]),'()')
                                    rmdPath=[rmdPath '.' subName];
                                elseif l==3 && isequal(rmdPathSplit{l}([1 end]),'()')
                                    rmdPath=[rmdPath '.' trialName];
                                else
                                    rmdPath=[rmdPath '.' rmdPathSplit{l}];
                                end
                            end
                        end
                        assignin('base','newPath',rmdPath);
                        if evalin('base',['existField(projectStruct,newPath)'])==1
                            evalin('base',[rmdPath '=rmfield(' rmdPath ', ''' argsPaths.(dataField){k}(dotIdx(end)+1:end) ''');']);
                            if evalin('base',['isempty(fieldnames(' rmdPath '))'])
                                dotIdx=strfind(rmdPath,'.');
                                newRmdPath=rmdPath(1:dotIdx(end)-1); % Remove the variable field name if empty
                                evalin('base',[newRmdPath '=rmfield(' newRmdPath ', ''' rmdPath(dotIdx(end)+1:end) ''');']);
                            end
                        end
                        evalin('base','clear newPath;');
                    end

                end

            end

            %% Add processing groups' data to load/offload list.
            if ~(isequal(groupNames{1},'Create Group Name') && length(groupNames)==1)

                groupFldNames=fieldnames(allGroups);
                for i=1:length(groupFldNames)

                    groupFldName=groupFldNames{i};                    

                    if isequal(allGroups.(groupFldName).Action,'Load')

                        disp(['Now Loading ' subName ' Trial ' trialName ' Group ' groupFldName]);

                        if exist(fullPathMat,'file')==2
                            currFcns=allGroups.(groupFldName).FunctionNames;
                            for j=1:length(currFcns)
                                currFcn=[currFcns{j} allGroups.(groupFldName).FunctionNumber{j}];
                                currPaths=argsPaths.(currFcn);
                                for k=1:length(currPaths)
                                    dotIdx=strfind(currPaths{k},'.');
                                    trialPath=currPaths{k}(dotIdx(3)+1:end);
                                    newPathSplit=strsplit(currPaths{k},'.');
                                    for l=1:length(newPathSplit)
                                        if l==1
                                            newPath=newPathSplit{1};
                                        else
                                            if l==2 && isequal(newPathSplit{l}([1 end]),'()')
                                                newPath=[newPath '.' subName];
                                            elseif l==3 && isequal(newPathSplit{l}([1 end]),'()')
                                                newPath=[newPath '.' trialName];
                                            else
                                                newPath=[newPath '.' newPathSplit{l}];
                                            end
                                        end
                                    end
                                    assignin('base','newPath',newPath);
                                    if evalin('base',['existField(projectStruct,newPath)'])==1
                                        evalin('base',[currPaths{k} '=trialData.' trialPath ';']);
                                    end
                                    evalin('base','clear newPath;');
                                end

                            end
                        end

                    elseif isequal(allGroups.(groupFldName).Action,'Offload')

                        disp(['Now Offloading ' subName ' Trial ' trialName ' Group ' groupFldName]);

                        currFcns=allGroups.(groupFldName).FunctionNames;
                        for j=1:length(currFcns)
                            currFcn=[currFcns{j} allGroups.(groupFldName).FunctionNumber{j}];
                            currPaths=argsPaths.(currFcn);
                            for k=1:length(currPaths)
                                dotIdx=strfind(currPaths{k},'.');
                                argPath=currPaths{k};
                                argPath=argPath(1:dotIdx(end)-1);
                                argPathSplit=strsplit(argPath,'.');
                                for l=1:length(argPathSplit)
                                    if l==1
                                        argPath=argPathSplit{1};
                                    else
                                        if l==2 && isequal(argPathSplit{l}([1 end]),'()')
                                            argPath=[argPath '.' subName];
                                        elseif l==3 && isequal(argPathSplit{l}([1 end]),'()')
                                            argPath=[argPath '.' trialName];
                                        else
                                            argPath=[argPath '.' argPathSplit{l}];
                                        end
                                    end
                                end
                                assignin('base','newPath',argPath);
                                if evalin('base',['existField(projectStruct,newPath)'])==1
                                    evalin('base',[argPath '=rmfield(' argPath ', ''' currPaths{k}(dotIdx(end)+1:end) ''');']);
                                    if evalin('base',['isempty(fieldnames(' argPath '))'])
                                        dotIdx=strfind(argPath,'.');
                                        newArgPath=argPath(1:dotIdx(end)-1); % Remove the variable field name if empty
                                        evalin('base',[newArgPath '=rmfield(' newArgPath ', ''' argPath(dotIdx(end)+1:end) ''');']);
                                    end
                                end
                                evalin('base','clear newPath;');
                            end

                        end  

                    end

                end

            end

        end

        evalin('base','clear trialData;');

    end

    evalin('base','clear subjData;');

end

evalin('base','clear projData');