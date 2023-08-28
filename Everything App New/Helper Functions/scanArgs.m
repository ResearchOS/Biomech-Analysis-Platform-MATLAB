function [args] = scanArgs(path)

%% PURPOSE: SCAN .M FILES FOR THE NAMES IN CODE OF THE ARGUMENTS.

args = {};

%% Check for syntax errors.
% http://matlab.izmiran.ru/help/techdoc/matlab_env/edit_d26.html#:~:text=To%20check%20for%20syntax%20errors,file%2C%20use%20the%20pcode%20function.&text=The%20MATLAB%20Editor%2FDebugger%20and,change%20the%20values%20they%20contain.
try 
    [folder, name, ext] = fileparts(path);    
    pcode(path,'-inplace');
    pPath = [folder filesep name '.p'];
    delete(pPath);
catch e
    disp(e.message);
    return;
end

text = regexp(fileread(path),'\n', 'split')';
if contains(text{1},'function')
    text = [text(1); {';'}; text(2:end)];
else
    text = [{';'}; text];
end

inStr = 'getArg';
outStr = 'setArg';

inIdxNums = find(contains(text,inStr)==1);
outIdxNums = find(contains(text,outStr)==1);

%% Ensure that none of the getArg and setArg are commented out.
for inOut = 1:2
    if inOut==1
        idxNums = inIdxNums;
    elseif inOut==2
        idxNums = outIdxNums;
    end
    delIdx = [];
    for i=1:length(idxNums)
        line = text{idxNums(i)};
        percIdxNum = strfind(line,'%');
        if isempty(percIdxNum) || percIdxNum>idxNums(i)
            continue;
        end
        delIdx = [delIdx; i];
    end
    idxNums(delIdx) = [];
    if inOut==1
        inIdxNums = idxNums;
    elseif inOut==2
        outIdxNums = idxNums;
    end
end

%% getArg parsing
% 1. Remove all spaces from the file. This leaves one long string with no
% spaces, but preserves newlines.
% 2. Find the character just before the '=' for '=getArg'. 
%   - If it is a ']', look for the first '[' before it (that is not preceded by a '%' on that same line). Everything between
%       them are input variables, separated by commas and/or spaces
%   - If it is any other character, look for the first '%' or ';' before
%   the equals sign.
%       - If it is a '%', get the first newline character after it (plus 1). That's
%       the start of the input variables.
% 3. Remove any line separators including newline (char(10)), and '...'
% 4. If any variable names are not valid MATLAB variable names (they
% include non-alphanumeric characters), throw an error.

%% setArg parsing
% 1. Remove all spaces from the file. This leaves one longs tring with no
% spaces, but preserves newlines.
% 2. Find all occurrences of 'setArg(' that are not preceded by a '%' in that line.
% 3. Find the next ')'. If the next character is not one of
% {';','%',char(10)}, then throw an error because a proper variable name
% was not entered.
% 4. Parse the variable names, as they are separated by commas. If any
% variable names are not valid MATLAB variable names (they include
% non-alphanumeric characters), throw an error.

% Get the line numbers for each getArg and setArg
% Get the line numbers for the semicolon before and after each getArg and setArg
% Reconstruct each getArg and setArg statement (in case they were
% multi-line). Then parse them for input variables.
for inOut = 1:2
    if inOut==1
        idxNums = inIdxNums;
        startLines = idxNums-1;
    elseif inOut==2
        idxNums = outIdxNums;
        startLines = idxNums;
    end
    prevSemicolonIdx = NaN(size(idxNums));    
    for i=1:length(idxNums)        
        if inOut==1
            tmpSemiColonIdx = find(contains(flip(text(1:startLines(i))),';'),1,'first'); % Count before current getArg
        else
            tmpSemiColonIdx = find(contains(text(startLines(i):end),';'),1,'first'); % Count after setArg (includes current line)
        end
        prevSemicolonIdx(i) = tmpSemiColonIdx-1;
        if isempty(tmpSemiColonIdx)
            error('How?!');            
        end
    end
    if inOut==1
        prevSemicolonIdxIn = idxNums-prevSemicolonIdx; % Earliest line number where getArg statement could start.
    elseif inOut==2
        prevSemicolonIdxInOut = idxNums+prevSemicolonIdx; % Line number where statement ends.
    end
end