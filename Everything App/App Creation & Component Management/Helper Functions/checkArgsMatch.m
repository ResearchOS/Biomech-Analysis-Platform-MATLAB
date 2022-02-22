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

% % Get the list of local functions found in the args file.
% fcnCount=0;
% for i=1:length(argsText)
% 
%     currLine=argsText{i}(~isspace(argsText{i}));
% 
%     if isempty(currLine)
%         continue; % Skip empty lines
%     end
% 
%     if length(currLine)>=length('function') && ~isequal(currLine(1:length('function')),'function')        
%         continue;
%     end   
% 
%     if length(currLine)>=length('function') && isequal(currLine(1:length('function')),'function')
%         fcnCount=fcnCount+1;
%         if fcnCount==1
%             continue;
%         end        
%     else
%         continue;
%     end
% 
%     percIdx=strfind(currLine,'%');
% 
%     if ~isempty(percIdx) && percIdx<startIdx
%         continue; % This line has been commented out, skip it.
%     end
% 
%     for j=1:length(argNames)
%         if isempty(strfind(currLine,argNames{j}))
%             warning('Terminating Processing!');
%             disp(['Argument ''' argNames{j} ''' called in: ' processFilePath]);
%             disp(['Missing In: ' argsFilePath]);
%             ok=0;
%             return;
%         end
%     end
% 
% end