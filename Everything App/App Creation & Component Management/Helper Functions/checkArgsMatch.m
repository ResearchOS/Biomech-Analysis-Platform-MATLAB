function [ok]=checkArgsMatch(processFilePath,argsFilePath,argStruct,levelIn)

%% PURPOSE: ENSURE THAT ALL ARGS CALLED BY GETARG IN THE PROCESSING FUNCTION APPEAR IN THE CORRESPONDING ARGUMENTS FILE.
% Inputs:
% processFilePath: The full path name to the current processing function (char)
% argFilePath: The full path name to the current argument function (char)
% argStruct: The output of the arguments function (struct)

processText=regexp(fileread(processFilePath),'\n','split'); % Each line is one element of the cell now.
% argsText=regexp(fileread(argsFilePath),'\n','split'); % Each line is one element of the cell now.

argStructNames=fieldnames(argStruct);

% Get the list of args called by the process function
ok=1;
for i=1:length(processText)

%     disp(i);

    currLine=processText{i}(~isspace(processText{i}));

    startIdxGet=strfind(currLine,'getArg(');
    startIdxSet=strfind(currLine,'setArg(');

    assert(length(startIdxGet)<=1 && length(startIdxSet)<=1); % No multiples of get and set
    assert(length(startIdxGet)+length(startIdxSet)<=1); % No get and set in the same line

    if isempty(startIdxGet) && isempty(startIdxSet)
        continue; % Skip this line if it doesn't have a getArg call.
    end

    percIdx=strfind(currLine,'%');

    if ~isempty(percIdx) && ((~isempty(startIdxGet) && percIdx(1)<startIdxGet) || (~isempty(startIdxSet) && percIdx(1)<startIdxSet))
        continue; % This line has been commented out, skip it.
    end

    semicolonIdx=strfind(currLine,';');
    threeDotIdx=strfind(currLine,'...');

    if isempty(semicolonIdx) && isempty(threeDotIdx)
        ok=0;
        warning('Terminating Processing Due to Error Reading Args File!');
        disp(['Argument ''' argName ''' called in: ' processFilePath]);
        disp(['Missing End of Line Character (; or ...): ' argsFilePath]);
        return; % This line is missing a terminating character.
    end    

    if ~isempty(startIdxGet) % getArg call

%         charStartIdx=startIdxGet+length('getArg(')+2; % First char of the argument
%         charEndIdx=strfind(currLine(charStartIdx:end),'''')+charStartIdx-2; % Final char of the argument

        currArgs=strsplit(currLine,"'"); % Split by apostrophes
        currArgs=currArgs(2:end); % Ignore the stuff to the left of the first argument
        splitLevels=strsplit(currArgs{end},',');
        currArgs=currArgs(1:end-1);
        idxVect=true(length(currArgs),1);
        for j=1:length(currArgs)
            if ~any(isstrprop(currArgs{j},'alpha'))
                idxVect(j)=false;
                currArgs=currArgs(idxVect); % Omit the current entry
                idxVect=true(length(currArgs),1);
                if j==length(currArgs)
                    break;
                end
            end
        end
        if contains(splitLevels{1},'}')
            splitLevels=splitLevels(2:end); % Omit the ending bracket if applicable
        end

        switch length(splitLevels)
            case 0 % Project level
                currLevel='Project';
            case 1 % Subject level
                currLevel='Subject';
            otherwise % Trial level
                currLevel='Trial';
        end

        if isequal(currLevel,levelIn)
%             argName=currLine(charStartIdx:charEndIdx);

            if ~ismember(currArgs,argStructNames)
                ok=0;
                warning('Terminating Processing Due to Incorrect Arg Name!');
                disp(['Argument ''' currArgs(~ismember(currArgs,argStructNames)) ''' called in: ' processFilePath]);
                disp(['Missing In: ' argsFilePath]);
                return;
            end
        end

    elseif ~isempty(startIdxSet) % setArg call

%         if exist('prevLine','var') && ~contains(prevLine,'...')
%             wholeLine=currLine;
%             charStartIdx=startIdxSet+length('setArg(')+1; % First char of the argument
%         else
%             wholeLine=[wholeLine currLine];
%             charStartIdx=1;
%         end
%         
%         if ~contains(currLine,'...') % Check if the setArg went multi-line
%             argNames=strsplit(wholeLine(charStartIdx-1:semicolonIdx-2),',');
%             argNames=argNames(4:end);
%         end

        if isequal(currLine(1:4),'eval')
            continue;
        end

        currArgs=strsplit(currLine(8:end),','); % Split by apostrophes
        currArgsEndSplit=strsplit(currArgs{end},')');
        currArgs{end}=currArgsEndSplit{1};
        for j=1:length(currArgs)
            try
                if isempty(eval(currArgs{j}))
                    break;
                end
            catch                
            end
        end

        switch j
            case 1 % Project
                currLevel='Project';
            case 2 % Subject
                currLevel='Subject';
            otherwise % Trial
                currLevel='Trial';
        end

        currArgs=currArgs(4:end); % Ignore the indices before the first argument
        
        if isequal(currLevel,levelIn)

            if ~all(ismember(currArgs,argStructNames))
                ok=0;
                warning('Terminating Processing Due to Incorrect Arg Name!');
                disp(['Argument ''' currArgs(~ismember(currArgs,argStructNames)) ''' called in: ' processFilePath]);
                disp(['Missing In: ' argsFilePath]);
                return;
            end

        end

    end

    prevLine=currLine;

end