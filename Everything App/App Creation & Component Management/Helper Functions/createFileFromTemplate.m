function []=createFileFromTemplate(templatePath,newPath,firstLine)

%% PURPOSE: CREATE A NEW .M FILE FROM THE TEMPLATE, MODIFYING THE FIRST LINE TO HAVE THE APPROPRIATE INPUT & OUTPUT ARGS & FUNCTION NAME
% Inputs:
% templatePath: The full file path of the template to copy, including the extension (char)
% newPath: The location to copy the template to (char)
% firstLine: The full contents of the new first line of the new function (char)

copyfile(templatePath,newPath); % Copy the file to the new location. Makes the new location if it does not already exist.
A=regexp(fileread(newPath),'\n','split'); % Open the newly created file
A{1}=firstLine; % Set the first line of the text
fid=fopen(newPath,'w');
fprintf(fid,'%s\n',A{1:end-1});
fprintf(fid,'%s',A{end});
fclose(fid);
edit(newPath); % Open the new file