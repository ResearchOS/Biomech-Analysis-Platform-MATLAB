function []=openPathWithDefaultApp(fullPath)

%% PURPOSE: RUNS A SHELL COMMAND TO OPEN THE SPECIFIED FOLDER/FILE USING THE DEFAULT APP.

if ispc==1
    winopen(fullPath);
    return;
end

%% For Mac.
spaceSplit=strsplit(fullPath,' ');

newPath='';
for i=1:length(spaceSplit)
    if i>1        
        mid='\ ';
    else
        mid='';
    end
    newPath=[newPath mid spaceSplit{i}];
end

system(['open ' newPath]);


% What about this as an alternate method for Mac?
% newPath=['''' path ''''];