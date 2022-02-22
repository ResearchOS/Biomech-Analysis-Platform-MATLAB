function [ok]=checkArgsMatch(processFilePath,argsFilePath)

%% PURPOSE: ENSURE THAT ALL ARGS CALLED BY GETARG IN THE PROCESSING FUNCTION APPEAR IN THE CORRESPONDING ARGUMENTS FILE.

processText=regexp(fileread(processFilePath),'\n','split'); % Each line is one element of the cell now.
% argsText=regexp(fileread(argsFilePath),'\n','split'); % Each line is one element of the cell now.

% Get the list of args called by the process function
ok=1;
for i=1:length(processText)

    currLine=processText{i}(~isspace(processText{i}));

    startIdx=strfind(currLine,'getArg(');

    assert(length(startIdx)<=1);

    if isempty(startIdx)
        continue; % Skip this line if it doesn't have a getArg call.
    end

    percIdx=strfind(currLine,'%');

    if ~isempty(percIdx) && percIdx(1)<startIdx
        continue; % This line has been commented out, skip it.
    end

    charStartIdx=startIdx+length('getArg(')+1; % First char of the argument
    charEndIdx=strfind(currLine(charStartIdx:end),'''')+charStartIdx-2; % Final char of the argument

    argName=currLine(charStartIdx:charEndIdx);

    str=which(argName,'in',argsFilePath);

    if isempty(str) || ~isequal(str,argsFilePath)
        ok=0;
        warning('Terminating Processing!');
        disp(['Argument ''' argName ''' called in: ' processFilePath]);
        disp(['Missing In: ' argsFilePath]);
        return;
    end

end