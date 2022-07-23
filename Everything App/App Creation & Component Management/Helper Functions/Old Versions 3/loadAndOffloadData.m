function []=loadAndOffloadData(matFilePath,pathsByLevel,level,subName,trialName)

%% PURPOSE: LOAD AND OFFLOAD DATA TO/FROM THE PROJECTSTRUCT AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL.
% Inputs:
% matFilePath: The full path to the mat file to load (char)
% pathsByLevel: All of the path names to be loaded or unloaded, split by level (struct)
% level: Specify which level to operate on data at (char)
% subName: The current subject's name, if necessary (char)
% trialName: The  current trial's name, if necessary (char)

% Outputs:
% None: Data is assigned to the projectStruct in the base workspace.

fldNames=fieldnames(pathsByLevel); % Data types and individual processing function names
dataLevelNames={'projData','subjData','trialData'};

loadedFile=0; % Initialize that the file has not been loaded yet.

for type=1:2
    if type==1
        currAction='Offload';
        
    elseif type==2
        currAction='Load';
    end

    for i=1:length(fldNames)

        if isfield(pathsByLevel.(fldNames{i}),level) && isequal(pathsByLevel.(fldNames{i}).Action,currAction)
            paths=pathsByLevel.(fldNames{i}).(level);

            switch currAction
                case 'Offload'
                    if evalin('base','exist(''projectStruct'',''var'') && ~isstruct(projectStruct)')
                        continue; % Skip this offloading if projectStruct does not exist
                    end

                    for j=1:length(paths)

                        rmdPath=paths{j};
                        dotIdx=strfind(rmdPath,'.');
                        rmdPath=rmdPath(1:dotIdx(end)-1);
                        rmdPathSplit=strsplit(rmdPath,'.');
                        for k=1:length(rmdPathSplit)
                            if k==1
                                rmdPath=rmdPathSplit{1};
                            else
                                if ismember(level,{'Subject','Trial'}) && k==2 && isequal(rmdPathSplit{k}([1 end]),'()')
                                    rmdPath=[rmdPath '.' subName];
                                elseif ismember(level,{'Trial'}) && k==3 && isequal(rmdPathSplit{k}([1 end]),'()')
                                    rmdPath=[rmdPath '.' trialName];
                                else
                                    rmdPath=[rmdPath '.' rmdPathSplit{k}];
                                end
                            end
                        end

                        assignin('base','newPath',rmdPath);
                        if evalin('base',['existField(projectStruct,newPath)'])==1
                            evalin('base',[rmdPath '=rmfield(' rmdPath ', ''' paths{j}(dotIdx(end)+1:end) ''');']);
                            % Option to recursively remove fieldnames for all fields that are empty.
                        end
                        evalin('base','clear newPath;');

                    end

                case 'Load'

                    if (exist(matFilePath,'file')~=2 || redoVal==1) && isequal(level,'Trial') % If the current trial does not have an existing MAT file, or if redo is specified, run the import function.

                    end

                    if loadedFile==0 && exist(matFilePath,'file')==2 % File exists but has not been loaded yet.
                        loadedFile=1;
                        currData=load(matFilePath);
                        fldName=fieldnames(currData);
                        assert(length(fldName)==1);
                        currData=currData.(fldName{1});
                    end

                    for j=1:length(paths)
                        dotIdx=strfind(paths{j},'.');
                        dotNum=find(ismember({'Project','Subject','Trial'},level)==1);
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

                        currData=dataLevelNames{dotNum};
                        if evalin('base',['exist(''' currData ''',''var'')~=1'])
                            switch level
                                case 'Project'
                                    disp(['Project Data Does Not Exist To Load']);
                                case 'Subject'
                                    disp(['Subject ' subName ' Data Does Not Exist To Load']);
                                case 'Trial'
                                    disp(['Subject ' subName ' Trial ' trialName ' Data Does Not Exist To Load']);
                            end
                            continue;
                        end
                        if evalin('base',['existField(' currData ',''' currData '.' path ''')'])
                            evalin('base',[newPath '=' currData '.' path ';']);
                        else
                            disp(['Data to be loaded from MAT is missing, but proceeding with Import: ' newPath]);
                        end

                    end

            end


        end

    end


end