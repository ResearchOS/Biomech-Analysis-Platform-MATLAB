function []=loadData(matFilePath,redoVal,pathsByLevel,level,subName,trialName,rawDataFileNames,logRow,logHeaders)

%% PURPOSE: LOAD DATA TO THE PROJECTSTRUCT AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL.
% Inputs:
% matFilePath: The full path to the mat file to load (char)
% redoVal: 1 to redo import, 0 not to.
% pathsByLevel: All of the path names to be loaded or unloaded, split by level (struct)
% level: Specify which level to operate on data at (char)
% subName: The current subject's name, if necessary (char)
% trialName: The  current trial's name, if necessary (char)

% Outputs:
% None: Data is assigned to the projectStruct in the base workspace.

fldNames=fieldnames(pathsByLevel); % Data types and individual processing function names

loadedFile=0; % Initialize that the file has not been loaded yet.

for i=1:length(fldNames)

    if isfield(pathsByLevel.(fldNames{i}),level) && isequal(pathsByLevel.(fldNames{i}).Action,'Load')
        paths=pathsByLevel.(fldNames{i}).(level);

        % If the current field name is a data type to be imported, and the current trial does not have an existing MAT file or if redo is specified, run the import function.
        if isfield(pathsByLevel.(fldNames{i}),'ImportFcnName') && (exist(matFilePath,'file')~=2 || redoVal==1) && isequal(level,'Trial')

            disp(['Now Importing ' subName ' Trial ' trialName ' ' fldNames{i} ' ' pathsByLevel.(fldNames{i}).MethodNum pathsByLevel.(fldNames{i}).MethodLetter]);

            feval(pathsByLevel.(fldNames{i}).ImportFcnName,rawDataFileNames.(fldNames{i}),logRow,logHeaders,subName,trialName);
            continue;
        end

        if loadedFile==0 && exist(matFilePath,'file')==2 % File exists but has not been loaded yet.
            loadedFile=1; 
            disp(['Now Loading ' subName ' Trial ' trialName ' ' fldNames{i} ' ' pathsByLevel.(fldNames{i}).MethodNum pathsByLevel.(fldNames{i}).MethodLetter]);
            currData=load(matFilePath);
            fldName=fieldnames(currData);
            assert(length(fldName)==1);
            currData=currData.(fldName{1});
        elseif exist(matFilePath,'file')~=2 % File does not exist.
            switch level
                case 'Project'
                    disp(['Project Data Does Not Exist To Load: ' matFilePath]);
                case 'Subject'
                    disp(['Subject ' subName ' Data Does Not Exist To Load: ' matFilePath]);
                case 'Trial'
                    disp(['Subject ' subName ' Trial ' trialName ' Data Does Not Exist To Load: ' matFilePath]);
            end
            return;
        end

        for j=1:length(paths)
            dotIdx=strfind(paths{j},'.');
            dotNum=fismember({'Project','Subject','Trial'},level);
            path=paths{j}(dotIdx(dotNum)+1:end);
            newPathSplit=strsplit(paths{j},'.');
            for k=1:length(newPathSplit)
                if k==1
                    newPath=newPathSplit{1};
                else
                    if ismember(level,{'Subject','Trial'}) && k==2 && isequal(newPathSplit{k}([1 end]),'()')
                        newPath=[newPath '.' subName];
                    elseif ismember(level,{'Trial'}) && k==3 && isequal(newPathSplit{k}([1 end]),'()')
                        newPath=[newPath '.' trialName];
                    else
                        newPath=[newPath '.' newPathSplit{k}];
                    end
                end

            end

            if existField(currData,['currData.' path])
                path=['currData.' path];
                newData=eval(path);
                assignin('base','newData',newData);
                evalin('base',[newPath '=newData;']);
            else
                disp(['Data to be loaded from MAT is missing: ' newPath]);
            end

        end

    end

end

evalin('base','clear newData;');