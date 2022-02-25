function [ok]=checkAllPaths(paths,projectStruct,allTrialNames,argsFilePath)

%% PURPOSE: ENSURE THAT ALL DATA THAT WILL BE CALLED IN A PROCESSING FUNCTION IS FOUND IN THE PROJECTSTRUCT
% Inputs:
% paths: Path names in projectStruct of all data (cell array of charsO
% projectStruct: The entire project's data (struct)
% allTrialNames: All subjects all trial names of interest (struct)

% Outputs:
% ok: 1 if all data is present, otherwise 0.


ok=1;

subNames=fieldnames(allTrialNames);
for i=1:length(paths)

    path=paths{i};
    pathSplit=strsplit(path,'.');
    if length(pathSplit)>=3 && isequal(pathSplit{3}([1 end]),'()')
        level='Trial';
    elseif length(pathSplit)>=2 && isequal(pathSplit{2}([1 end]),'()')
        level='Subject';
    else
        level='Project';
    end

    if isequal(level,'Project')
        if existField(projectStruct,path)
            continue;
        else
            ok=0;
            warning('Terminating Processing!');
            disp(['Argument ''' argName ''' called in: ' argsFilePath]);
            disp(['Missing In: ' path]);
            return;
        end
    end

    for subNum=1:length(subNames)

        subName=subNames{subNum};
        if isequal(level,'Subject')
            newPath=[pathSplit{1} '.' subName];
            for j=3:length(pathSplit)
                newPath=[newPath '.' pathSplit{j}];
            end
            if existField(projectStruct,newPath)
                continue;
            else
                ok=0;
                warning('Terminating Processing!');
                disp(['Missing in projectStruct: ' newPath]);
                disp(['Called In: ' argsFilePath]);
                return;
            end
        end

        trialNames=fieldnames(allTrialNames.(subName));

        for trialNum=1:length(trialNames)

            trialName=trialNames{trialNum};

            for repNum=allTrialNames.(subName).(trialName)
                if isequal(level,'Trial')
                    newPath=[pathSplit{1} '.' subName '.' trialName];
                    for j=4:length(pathSplit)
                        if j==4 && contains(pathSplit{j},'(')
                            openParensIdx=strfind(pathSplit{j},'(');
                            newPath=[newPath '.' pathSplit{j}(1:openParensIdx-1) '(' num2str(repNum) ')'];
                        else
                            newPath=[newPath '.' pathSplit{j}];
                        end
                    end
                    if existField(projectStruct,newPath,repNum)
                        continue;
                    else
                        ok=0;
                        warning('Terminating Processing!');
                        disp(['Missing in projectStruct: ' newPath]);
                        disp(['Called In: ' argsFilePath]);
                        return;
                    end
                end
            end

        end

    end



end