function [path] = getPathFromPicker(initPath)

%% PURPOSE: RETURN THE PATH SELECTED BY THE USER

if exist(initPath,'dir')~=7
    initPath = userpath;
end

path=uigetdir(initPath,'Select the folder containing the data');

if path==0
    path = '';
end

if exist(path,'dir')==7
    return;
end


if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist');
    return;
end