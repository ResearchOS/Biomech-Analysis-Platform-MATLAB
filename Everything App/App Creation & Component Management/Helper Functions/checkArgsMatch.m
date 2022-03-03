function [ok]=checkArgsMatch(processFilePath,argsFilePath,argStruct)

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

    if ~isempty(startIdxGet)

        charStartIdx=startIdxGet+length('getArg(')+1; % First char of the argument
        charEndIdx=strfind(currLine(charStartIdx:end),'''')+charStartIdx-2; % Final char of the argument

        argName=currLine(charStartIdx:charEndIdx);

        if ~ismember(argName,argStructNames)
            ok=0;
            warning('Terminating Processing Due to Incorrect Arg Name!');
            disp(['Argument ''' argName ''' called in: ' processFilePath]);
            disp(['Missing In: ' argsFilePath]);
            return;
        end

%         str=which(argName,'in',argsFilePath);
% 
%         if isempty(str) || ~isequal(str,argsFilePath)
%             ok=0;
%             
%         end

    elseif ~isempty(startIdxSet)

        if exist('prevLine','var') && ~contains(prevLine,'...')
            wholeLine=currLine;
            charStartIdx=startIdxSet+length('setArg(')+1; % First char of the argument
        else
            wholeLine=[wholeLine currLine];
            charStartIdx=1;
        end
        
        if ~contains(currLine,'...') % Check if the setArg went multi-line
            argNames=strsplit(wholeLine(charStartIdx-1:semicolonIdx-2),',');
            argNames=argNames(4:end);
        end

        for j=1:length(argNames)
            
            argName=argNames{j};

            if ~ismember(argName,argStructNames)
                ok=0;
                warning('Terminating Processing Due to Incorrect Arg Name!');
                disp(['Argument ''' argName ''' called in: ' processFilePath]);
                disp(['Missing In: ' argsFilePath]);
                return;
            end

%             str=which(argNames{j},'in',argsFilePath);
% 
%             if isempty(str) || ~isequal(str,argsFilePath)
%                 ok=0;
%                 warning('Terminating Processing!');
%                 disp(['Argument ''' argNames{j} ''' called in: ' processFilePath]);
%                 disp(['Missing In: ' argsFilePath]);
%                 return;
%             end

        end

    end

    prevLine=currLine;

end