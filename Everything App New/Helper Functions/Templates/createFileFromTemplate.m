function []=createFileFromTemplate(templatePath,newPath,fcnName,args)

%% PURPOSE: CREATE A NEW .M FILE FROM THE TEMPLATE, MODIFYING THE FIRST LINE TO HAVE THE APPROPRIATE INPUT & OUTPUT ARGS & FUNCTION NAME
% Inputs:
% templatePath: The full file path of the template to copy, including the extension (char)
% newPath: The location to copy the template to (char)
% fcnName: The newly created function name (char)

copyfile(templatePath,newPath); % Copy the file to the new location. Makes the new location if it does not already exist.
A=regexp(fileread(newPath),'\n','split'); % Open the newly created file

argsStr='';
for i=1:length(args)
    argsStr=[argsStr args{i} ', '];
end
argsStr=argsStr(1:end-2);

firstLine=['function []=' fcnName '(' argsStr ')'];

A{1}=firstLine; % Set the first line of the text
fid=fopen(newPath,'w');
fprintf(fid,'%s\n',A{1:end-1});
fprintf(fid,'%s',A{end});
fclose(fid);
edit(newPath); % Open the new file