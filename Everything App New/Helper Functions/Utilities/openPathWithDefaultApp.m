function []=openPathWithDefaultApp(fullPath)

%% PURPOSE: RUNS A SHELL COMMAND TO OPEN THE SPECIFIED FOLDER/FILE USING THE DEFAULT APP.

if ispc==1
    winopen(fullPath);
    return;
end

%% For Mac.
newPath=['"' fullPath '"']; % Deal with spaces by enclosing in double quotes.
system(['open ' newPath]);
