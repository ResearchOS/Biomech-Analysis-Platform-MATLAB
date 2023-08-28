function [args] = scanArgs(path)

%% PURPOSE: SCAN .M FILES FOR THE NAMES IN CODE OF THE ARGUMENTS.

text = [];

inStr = 'getArg';
outStr = 'setArg';

inIdx = contains(text,inStr);
outIdx = contains(text,outStr);