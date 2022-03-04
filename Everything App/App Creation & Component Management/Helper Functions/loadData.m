function []=loadData(matFilePath,redoVal,pathsByLevel,level,subName,trialName,repNum,rawDataFileNames,logRow,logHeaders)

%% PURPOSE: LOAD DATA TO THE PROJECTSTRUCT AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL.
% Inputs:
% matFilePath: The full path to the mat file to load (char)
% redoVal: 1 to redo import, 0 not to.
% pathsByLevel: All of the path names to be loaded or unloaded, split by level (struct)
% level: Specify which level to operate on data at (char)
% subName: The current subject's name, if necessary (char)
% trialName: The  current trial's name, if necessary (char)
% repNum: The repetition number of the current trial name (double)
% rawDataFileNames: 
% logRow: Current row in the logsheet (cell array)
% logHeaders: First row of the logsheet (cell array)

% Outputs:
% None: Data is assigned to the projectStruct in the base workspace.

dataTypes=fieldnames(pathsByLevel.Action); % Data types and individual processing function names

for i=1:length(dataTypes)

    if ~(isfield(pathsByLevel.All.(dataTypes{i}),level) && isequal(pathsByLevel.Action.(dataTypes{i}),'Load'))
        continue;
    end

%     inputPaths=pathsByLevel.Inputs.(dataTypes{i}).(level);
    outputPaths=pathsByLevel.Outputs.(dataTypes{i}).(level);
    allPaths=pathsByLevel.All.(dataTypes{i}).(level);

    % If:
    % 1. the current field name is a data type to be imported, and
    % 2. the trial exists in the struct but there are fewer reps than the current rep number, or
    % 3. the trial does not exist in the structure, or
    % 4. if redo is specified, or
    % run the import function.

%     if ~isfield(pathsByLevel,'ImportFcnName') || ~isfield(pathsByLevel.ImportFcnName,dataTypes{i})
%         continue; % Skip this field if it is not a data type to be imported.
%     end

    if exist(matFilePath,'file')==2 && redoVal==0 % File exists but has not been loaded yet and is not being re-imported.

        switch level
            case 'Project'
                prefix='Project ';
            case 'Subject'
                prefix=[subName ' '];
            case 'Trial'
                prefix=[subName ' Trial ' trialName ' Repetition ' num2str(repNum) ' '];
        end

        if isfield(pathsByLevel,'ImportFcnName') && isfield(pathsByLevel.ImportFcnName,dataTypes{i})
            disp(['Now Loading ' prefix dataTypes{i} ' ' pathsByLevel.MethodNum.(dataTypes{i}) pathsByLevel.MethodLetter.(dataTypes{i})]);
        else
            disp(['Now Loading ' prefix dataTypes{i}]);
        end

        if ~exist('currData','var')
            currData=load(matFilePath);
            fldName=fieldnames(currData);
            assert(length(fldName)==1);
            currData=currData.(fldName{1});
        end

    end

    for j=1:length(allPaths)
        dotIdx=strfind(allPaths{j},'.');
        dotNum=ismember({'Project','Subject','Trial'},level);
        path=allPaths{j}(dotIdx(dotNum)+1:end);
        newPathSplit=strsplit(allPaths{j},'.');
        for k=1:length(newPathSplit)
            if k==1
                newPath=newPathSplit{1};
            else
                if ismember(level,{'Subject','Trial'}) && k==2 && isequal(newPathSplit{k}([1 end]),'()')
                    newPath=[newPath '.' subName];
                elseif ismember(level,{'Trial'}) && k==3 && isequal(newPathSplit{k}([1 end]),'()')
                    newPath=[newPath '.' trialName];
                elseif k==4 && all(ismember('()',newPathSplit{k})) && ~isequal(newPathSplit{k}([1 end]),'()')
                    openParensIdx=strfind(newPathSplit{k},'(');
                    newPath=[newPath '.' newPathSplit{k}(1:openParensIdx-1) '(' num2str(repNum) ')'];
                else
                    newPath=[newPath '.' newPathSplit{k}];
                end
            end

        end

        if exist('currData','var') && existField(currData,['currData.' path],repNum) && redoVal==0

            path=['currData.' path];
            newData=eval(path); % Add repetition number to path.
            assignin('base','newData',newData);
            evalin('base',[newPath '=newData;']);

        elseif isequal(level,'Trial') && isfield(rawDataFileNames,dataTypes{i}) && exist(rawDataFileNames.(dataTypes{i}),'file')==2

            disp(['Now Importing ' subName ' Trial ' trialName ' Repetition ' num2str(repNum) ' ' dataTypes{i} ' ' pathsByLevel.MethodNum.(dataTypes{i}) pathsByLevel.MethodLetter.(dataTypes{i})]);
            feval(pathsByLevel.ImportFcnName.(dataTypes{i}),rawDataFileNames.(dataTypes{i}),logRow,logHeaders,subName,trialName,repNum);
            break;

        elseif isfield(rawDataFileNames,dataTypes{i}) && exist(rawDataFileNames.(dataTypes{i}),'file')~=2

            disp(['Missing raw data file: ' rawDataFileNames.(dataTypes{i})]);
            return;

        else

            % When can I really say that the data is missing? Certainly if this is not a trial level (i.e. no import). But when else?
            disp(['Data to be loaded from MAT is missing: ' newPath]);

        end

    end

end

evalin('base','clear newData;');