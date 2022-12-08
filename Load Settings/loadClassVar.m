function [classVar]=loadClassVar(classFolder)

%% PURPOSE: GO THROUGH ALL OF THE FILES IN THE CLASS'S FOLDER AND LOAD THEM INTO MEMORY IF THEY HAVE 'VISIBLE' SET TO 1
listing=dir(classFolder);
fileNames={listing.name};
fileDirs=[listing.isdir];
fileNames=fileNames(~fileDirs); % Isolate the non-folder entries

% If there are no files, return an empty struct.
classVar=struct([]);
if isempty(fileNames)    
    return;
end

% If there are files, load them all to the class variable. Each index of the struct is one instance of the class
for i=1:length(fileNames)
    fileName=fileNames{i};

    % IN THE FUTURE MAYBE THERE SHOULD BE A TOGGLE FOR WHETHER TO USE JSON
    % OR .MAT FILES AS "GROUND TRUTH"? I FOUND THIS FEATURE TO BE ANNOYING
    % IN DEEPLABCUT THAT IT USED NON-HUMAN READABLE HDF5 FILES INSTEAD OF
    % MODIFIABLE CSV'S.
    fullPath=[classFolder slash fileName '.json']; % Get the name of the json file that the settings are saved to.
    % Read the json file as unformatted char
    fid=fopen(fullPath);
    raw=fread(fid,inf);
    str=char(raw');
    fclose(fid);

    % Convert json to struct
    settingsStruct=jsondecode(str);

%     if settingsStruct.Visible==0 % Visible=0 means that it was filtered out.
%         continue;
%     end
    classVar(i)=settingsStruct;
end