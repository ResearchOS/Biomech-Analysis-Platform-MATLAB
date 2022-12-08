function [id]=createID(src,class)

%% PURPOSE: CREATE AN ID NUMBER FOR THE CURRENTLY SPECIFIED CLASS
fig=ancestor(src,'figure','toplevel');

rootFolder=getappdata(fig,'everythingPath'); % Path to the "Biomech-Analysis-Platform" folder

slash=filesep;

classFolder=[rootFolder slash 'Classes' slash class];

files=dir(classFolder);
fileNames={files.name};
isDir=[files.isdir];
fileNames=fileNames(~isDir); % Remove folders from the list.

isNewID=false;
while ~isNewID
    newID=randi(16777215,1); % Max 6 digit hexadecimal value ('FFFFFF')

    if ~contains(fileNames,newID)
        isNewID=true;
    end
end

newID=dec2hex(newID); % Convert the randomly generated number to hexadecimal char
numDigits=length(newID);
id=[repmat('0',1,6-numDigits) newID]; % Ensure that the hex code is 6 digits long