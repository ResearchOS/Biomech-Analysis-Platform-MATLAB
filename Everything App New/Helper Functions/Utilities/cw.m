function []=cw(varargin)
% "CW" IS SHORT FOR "CLEAR WORKSPACE"

%% PURPOSE: LITERALLY JUST A SHORTHAND WAY OF CLEARING THE VARIABLE WORKSPACE BECAUSE I'M TIRED OF TYPING CLEARVARS

if nargin==0
    evalin('caller','clearvars;');
    return;
end

%% Specified variables are kept.
strCat='';
for i=1:length(varargin)
    strCat=[strCat varargin{i} ' '];
end
strCat=strCat(1:end-1); % Remove space

evalin('caller',['clearvars -except ' strCat ';']);