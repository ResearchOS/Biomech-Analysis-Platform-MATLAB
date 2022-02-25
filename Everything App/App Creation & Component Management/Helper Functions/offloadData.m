function []=offloadData(pathsByLevel,level,subName,trialName,repNum)

%% PURPOSE: LOAD DATA TO THE PROJECTSTRUCT AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL.
% Inputs:
% matFilePath: The full path to the mat file to load (char)
% pathsByLevel: All of the path names to be loaded or unloaded, split by level (struct)
% level: Specify which level to operate on data at (char)
% subName: The current subject's name, if necessary (char)
% trialName: The  current trial's name, if necessary (char)

% Outputs:
% None: Data is assigned to the projectStruct in the base workspace.

if evalin('base','exist(''projectStruct'',''var'') && ~isstruct(projectStruct)')
    return; % Skip this offloading if projectStruct does not exist
end

fldNames=fieldnames(pathsByLevel.All); % Data types and individual processing function names

for i=1:length(fldNames)

    if isfield(pathsByLevel.All.(fldNames{i}),level) && isequal(pathsByLevel.Action.(fldNames{i}),'Offload')
        paths=pathsByLevel.All.(fldNames{i}).(level);

        switch level
            case 'Project'
                prefix='Project ';
            case 'Subject'
                prefix=[subName ' '];
            case 'Trial'
                prefix=[subName ' Trial ' trialName ' Repetition ' num2str(repNum) ' '];
        end

        if isfield(pathsByLevel,'ImportFcnName') && isfield(pathsByLevel.ImportFcnName,fldNames{i})
            disp(['Now Offloading ' prefix fldNames{i} ' ' pathsByLevel.MethodNum.(fldNames{i}) pathsByLevel.MethodLetter.(fldNames{i})]);
        else
            disp(['Now Offloading ' prefix fldNames{i}]);
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
                    elseif k==4 && all(ismember('()',rmdPathSplit{k})) && ~isequal(rmdPathSplit{k}([1 end]),'()')
                        openParensIdx=strfind(rmdPathSplit{k},'(');
                        rmdPath=[rmdPath '.' rmdPathSplit{k}(1:openParensIdx-1) '(' num2str(repNum) ')'];
                    else
                        rmdPath=[rmdPath '.' rmdPathSplit{k}];
                    end
                end
            end

            assignin('base','newPath',rmdPath);
            assignin('base','repNum',repNum);
            if evalin('base',['existField(projectStruct,newPath,repNum);'])==1
                evalin('base',[rmdPath '=rmfield(' rmdPath ', ''' paths{j}(dotIdx(end)+1:end) ''');']);
                % Option to recursively remove fieldnames for all fields that are empty.
            end
            evalin('base','clear newPath repNum;');

        end

    end

end