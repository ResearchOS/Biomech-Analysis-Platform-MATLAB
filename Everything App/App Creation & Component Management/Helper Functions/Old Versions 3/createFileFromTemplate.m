function []=createFileFromTemplate(templatePath,newPath,fcnName)

%% PURPOSE: CREATE A NEW .M FILE FROM THE TEMPLATE, MODIFYING THE FIRST LINE TO HAVE THE APPROPRIATE INPUT & OUTPUT ARGS & FUNCTION NAME
% Inputs:
% templatePath: The full file path of the template to copy, including the extension (char)
% newPath: The location to copy the template to (char)
% fcnName: The newly created function name (char)

copyfile(templatePath,newPath); % Copy the file to the new location. Makes the new location if it does not already exist.
A=regexp(fileread(newPath),'\n','split'); % Open the newly created file

if isempty(strfind(A{1},'=')) % This is a Processing template function
    firstLine=['function ' fcnName A{1}(strfind(A{1},'('):end)]; % Insert the new function name in the first line
else
    firstLine=[A{1}(1:strfind(A{1},'=')) fcnName A{1}(strfind(A{1},'('):end)];
end

A{1}=firstLine; % Set the first line of the text
fid=fopen(newPath,'w');
fprintf(fid,'%s\n',A{1:end-1});
fprintf(fid,'%s',A{end});
fclose(fid);
edit(newPath); % Open the new file