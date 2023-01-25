function [varargout]=loadArg(dataPath,subName,trialName,repNum,varargin)

%% PURPOSE: RETURN INPUT ARGUMENTS. NON-INDEPENDENT VERSION OF "GETARG", ONLY TO BE USED IN UNFINISHED AREAS OF GUI, OR FOR QUICK CALCULATION

% How best to specify this?
% dataPath=[];

if isempty(subName)
    level='P';
else
    if isempty(trialName)
        level='S';
    else
        level='T';
    end
end

varargout=cell(size(varargin));

for i=1:length(varargin)

    switch level
        case 'P'
            varargout{i}=loadMAT(dataPath,varargin{i});
        case 'S'
            varargout{i}=loadMAT(dataPath,varargin{i},subName);
        case 'T'
            varargout{i}=loadMAT(dataPath,varargin{i},subName,trialName);
    end

end