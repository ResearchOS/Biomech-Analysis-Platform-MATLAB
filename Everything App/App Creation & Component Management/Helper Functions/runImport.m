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

    pathsByLevel.Action.(dataField)=dataTypeAction.(dataField);

    if isequal(dataTypeAction.(dataField),'Load')
        loadAnyTrial=1; % Indicates that trial level MAT files should be loaded.
    end

    % Function names to import each data type
    %     dataImportFcnNames{i}=[lower(dataField) '_Import' methodNumber.(dataField)];
    pathsByLevel.ImportFcnName.(dataField)=[lower(dataField) '_Import' methodNumber.(dataField)];

    % Import function args paths to read through
    dataImportArgsFcnNames{i}=[codePath 'Import_' getappdata(fig,'projectName') slash 'Arguments' slash lower(dataField) '_Import' methodNumber.(dataField) methodLetter.(dataField) '.m'];

    % Read through import function args and get all of the projectStruct
    % paths
    [argsPaths.Inputs.(dataField),argsPaths.Outputs.(dataField),argsPaths.All.(dataField)]=readArgsFcn(dataImportArgsFcnNames{i});

    trialCount=0; % The count of how many inputs paths there are at the trial level, per data type or processing group
    subjCount=0;
    projCount=0;

    % Split the argsPaths by project, subject, and trial level.
    for j=1:length(argsPaths.Inputs.(dataField))
        currPath=argsPaths.Inputs.(dataField){j};
        currPathSplit=strsplit(currPath,'.');
        if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')
            trialCount=trialCount+1;
            pathsByLevel.Inputs.(dataField).Trial{trialCount,1}=currPath;
        elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')
            subjCount=subjCount+1;
            pathsByLevel.Inputs.(dataField).Subject{subjCount,1}=currPath;
        else
            projCount=projCount+1;
            pathsByLevel.Inputs.(dataField).Project{projCount,1}=currPath;
        end
    end

    trialCount=0; % The count of how many outputs paths there are at the trial level, per data type or processing group
    subjCount=0;
    projCount=0;

    % Split the argsPaths by project, subject, and trial level.
    for j=1:length(argsPaths.Outputs.(dataField))
        currPath=argsPaths.Outputs.(dataField){j};
        currPathSplit=strsplit(currPath,'.');
        if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')
            trialCount=trialCount+1;
            pathsByLevel.Outputs.(dataField).Trial{trialCount,1}=currPath;
        elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')
            subjCount=subjCount+1;
            pathsByLevel.Outputs.(dataField).Subject{subjCount,1}=currPath;
        else
            projCount=projCount+1;
            pathsByLevel.Outputs.(dataField).Project{projCount,1}=currPath;
        end
    end

    trialCount=0; % The count of how many paths there are at the trial level, per data type or processing group
    subjCount=0;
    projCount=0;

    % Split the argsPaths by project, subject, and trial level.
    for j=1:length(argsPaths.All.(dataField))
        currPath=argsPaths.All.(dataField){j};
        currPathSplit=strsplit(currPath,'.');
        if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')
            trialCount=trialCount+1;
            pathsByLevel.All.(dataField).Trial{trialCount,1}=currPath;
        elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')
            subjCount=subjCount+1;
            pathsByLevel.All.(dataField).Subject{subjCount,1}=currPath;
        else
            projCount=projCount+1;
            pathsByLevel.All.(dataField).Project{projCount,1}=currPath;
        end
    end

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

        if isequal(action,'None')
            continue;
        end        

        % Iterate over all function names in that group
        for j=lineNums(i)+1:length(groupText)
            currLine=groupText{j};

            trialCountIn=0; % The count of how many inputs paths there are at the trial level, per data type or processing group
            subjCountIn=0;
            projCountIn=0;

            trialCountOut=0; % The count of how many outputs paths there are at the trial level, per data type or processing group
            subjCountOut=0;
            projCountOut=0;

            trialCount=0;
            subjCount=0;
            projCount=0;

            if isempty(currLine)
                break;
            end

            colonSplit=strsplit(currLine,':');
            beforeColon=strsplit(colonSplit{1},' ');
            fcnName=beforeColon{1};
            fcnLetter=beforeColon{2}(isletter(beforeColon{2}));
            fcnNum=beforeColon{2}(~isletter(beforeColon{2}));

            % Determine whether the function or group level args is specified.
            spaceSplit=strsplit(colonSplit{2},' ');

            if isequal(spaceSplit{4}(end),'1') % Function level args
                argsFcnName=[codePath 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Function' slash fcnName '_Process' fcnNum fcnLetter '.m'];
            elseif isequal(spaceSplit{4}(end),'0') % Group level args
                argsFcnName=[codePath 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash 'Per Group' slash fcnName '_Process' fcnNum fcnLetter '.m'];
            end           

            [argsPaths.Inputs.([fcnName fcnNum]),argsPaths.Outputs.([fcnName fcnNum]),argsPaths.All.([fcnName fcnNum])]=readArgsFcn(argsFcnName);

            pathsByLevel.Action.([fcnName fcnNum fcnLetter])=action;

            if ~isequal(action,'Load')
                continue; % If not loading the argsPaths, ignore the below code specifying which level of data to load.
            end

            for k=1:length(argsPaths.All.([fcnName fcnNum]))

                currPath=argsPaths.All.([fcnName fcnNum]){k};
                currPathSplit=strsplit(argsPaths.All.([fcnName fcnNum]){k},'.');
                if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()') % Dynamic trial name
                    loadAnyTrial=1;
                elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()') % Dynamic subject name
                    loadAnySubj=1;
                elseif length(currPathSplit)>=2
                    loadAnyProj=1;
                end

                % Split the argsPaths by project, subject, and trial level.
                if length(currPathSplit)>=3 && isequal(currPathSplit{3}([1 end]),'()')                    
                    if ismember(currPath,argsPaths.Inputs.([fcnName fcnNum]))
                        trialCountIn=trialCountIn+1;
                        pathsByLevel.Inputs.([fcnName fcnNum fcnLetter]).Trial{trialCountIn,1}=currPath;
                    end
                    if ismember(currPath,argsPaths.Outputs.([fcnName fcnNum]))
                        trialCountOut=trialCountOut+1;
                        pathsByLevel.Outputs.([fcnName fcnNum fcnLetter]).Trial{trialCountOut,1}=currPath;
                    end
                    trialCount=trialCount+1;
                    pathsByLevel.All.([fcnName fcnNum fcnLetter]).Trial{trialCount,1}=currPath;
                elseif length(currPathSplit)>=2 && isequal(currPathSplit{2}([1 end]),'()')                    
                    if ismember(currPath,argsPaths.Inputs.([fcnName fcnNum]))
                        subjCountIn=subjCountIn+1;
                        pathsByLevel.Inputs.([fcnName fcnNum fcnLetter]).Subject{subjCountIn,1}=currPath;
                    end
                    if ismember(currPath,argsPaths.Outputs.([fcnName fcnNum]))
                        subjCountOut=subjCountOut+1;
                        pathsByLevel.Outputs.([fcnName fcnNum fcnLetter]).Subject{subjCountOut,1}=currPath;
                    end
                    subjCount=subjCount+1;
                    pathsByLevel.All.([fcnName fcnNum fcnLetter]).Subject{subjCount,1}=currPath;
                else                    
                    if isequal(currPath,argsPaths.Inputs.([fcnName fcnNum]))
                        projCountIn=projCountIn+1;
                        pathsByLevel.Inputs.([fcnName fcnNum fcnLetter]).Project{projCountIn,1}=currPath;
                    end
                    if isequal(currPath,argsPaths.Outputs.([fcnName fcnNum]))
                        projCountOut=projCountOut+1;
                        pathsByLevel.Outputs.([fcnName fcnNum fcnLetter]).Project{projCountOut,1}=currPath;
                    end
                    projCount=projCount+1;
                    pathsByLevel.All.([fcnName fcnNum fcnLetter]).Project{projCount,1}=currPath;
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

for kk=1:2 % First offload everything, then load everything. This accounts for any overlap between groups and ensures that all data will be present as needed.

    for subNum=1:length(subNames)

        subName=subNames{subNum};
        trialNames=fieldnames(allTrialNames.(subName));

        fullPathSubjMat=[dataPath 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];

        % Iterate through all trial names in that subject (matches Target Trial ID logsheet column)
        for trialNum=1:length(trialNames)

            trialName=trialNames{trialNum}; % Trial name as it will be stored in the struct.

            fullPathMat=[dataPath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];

            %         if loadAnyTrial==1 && exist(fullPathMat,'file')==2
            %             trialData=load(fullPathMat); % Load the trial's MAT file.
            %             fldName=fieldnames(trialData);
            %             assert(length(fldName)==1);
            %             trialData=trialData.(fldName{1});
            %             assignin('base','trialData',trialData);
            %         end

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

            repNums=allTrialNames.(subName).(trialName);

            for repNum=repNums

                rowNum=rowNums(repNum);

                for i=1:length(dataTypes)
                    alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
                    dataField=dataTypes{i}(alphaNumericIdx);
                    dataTypeTrialColNum=colNum.(dataField);
                    letter=methodLetter.(dataField);
                    setappdata(fig,'methodLetter',letter);
                    number=methodNumber.(dataField);

                    fileName=logVar{rowNum,dataTypeTrialColNum};

                    if isempty(fileName) || all(isnan(fileName))
                        continue; % For trials that don't have all data present, ignore them for those data types.
                    end

                    fullPathRaw=[dataPath 'Raw Data Files' slash subName slash dataTypes{i} slash fileName];

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

                    rawDataFileNames.(dataField)=fullPathRaw;

                    pathsByLevel.MethodNum.(dataField)=number;
                    pathsByLevel.MethodLetter.(dataField)=letter;

                end

                logRow=logVar(rowNum,:);
                logHeaders=logVar(1,:);

                switch kk
                    case 1
                        offloadData(pathsByLevel,'Trial',subName,trialName,repNum);
                    case 2
                        loadData(fullPathMat,redoVal,pathsByLevel,'Trial',subName,trialName,repNum,rawDataFileNames,logRow,logHeaders);
                end

            end

            evalin('base','clear trialData;');

        end

        if loadAnySubj==1 && exist(fullPathSubjMat,'file')==2
            %% LOAD/OFFLOAD DATA TYPES' & PROCESSING GROUPS' SUBJECT-LEVEL DATA
            switch kk
                case 1
                    offloadData(pathsByLevel,'Subject',subName);
                case 2
                    loadData(fullPathSubjMat,redoVal,pathsByLevel,'Subject',subName);
            end
        end

    end

    fullPathProjMat=[dataPath 'MAT Data Files' slash projectName '.mat'];

    if loadAnyProj==1 && exist(fullPathProjMat,'file')==2
        %% LOAD/OFFLOAD DATA TYPES' & PROCESSING GROUPS' PROJECT-LEVEL DATA
        switch kk
            case 1
                offloadData(pathsByLevel,'Project');
            case 2
                loadData(fullPathProjMat,redoVal,pathsByLevel,'Project');
        end

    end

end

for sub=1:length(subNames)

    subName=subNames{sub};
%     trialNames=fieldnames(allTrialNames.(subName));

    evalin('base',['projectStruct.' subName '=orderfields(projectStruct.' subName ');' ]); % Rearrange trial names in alphabetical order.

end

evalin('base','projectStruct=orderfields(projectStruct);'); % Rearrange subject names in alphabetical order.