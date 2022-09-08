function [inputArgNamesInCode,outputArgNamesInCode]=readArgs(fig,fcnName)

%% PURPOSE: READ THE ARGUMENTS IN A FUNCTION. ARGUMENTS MUST BE SPECIFIED AS A CHAR OR CELL ARRAY IN THE GETARG LINE.
% NOTE: ASSIGNING A VARIABLE TO ALL OF THE ARGUMENT NAMES AND THEN USING THAT INPUT VARIABLE WILL NOT WORK, THE ACTUAL CELL ARRAY MUST BE PART OF THE
% GETARG CALL.

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

codePath=getappdata(fig,'codePath');
filePath=[codePath 'Processing Functions' slash fcnName '.m'];

text=fileread(filePath);

for j=1:2
    switch j
        case 1 % Input variables
            string='getArg(';
            varNamesInCode={};
        case 2 % Output variables
            string='setArg(';
            varNamesInCode={};
    end    
    
    sections=strsplit(text,string);
    sections=sections(2:end); % Ignore everything before the first getArg/setArg

    for i=1:length(sections) % For each instance of getArg/setArg

        subsection=strsplit(sections{i},';');
        subsection=subsection{1}; % Only need the text before the first semicolon
        argsText=subsection(~ismember(subsection,'{}'')(. []'));
        argNames=strsplit(argsText,',');
        argNames=argNames(~ismember(argNames,{'subName','trialName','repNum'}));
        varNamesInCode=[varNamesInCode; argNames'];

    end

    switch j
        case 1
            inputArgNamesInCode=varNamesInCode;
        case 2
            outputArgNamesInCode=varNamesInCode;
    end

end