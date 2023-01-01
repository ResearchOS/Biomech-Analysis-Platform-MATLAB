function [classVar]=loadClassVar(fig,classFolder)

%% PURPOSE: GO THROUGH ALL OF THE FILES IN THE CLASS'S FOLDER AND LOAD THEM INTO MEMORY IF THEY HAVE 'VISIBLE' SET TO 1
slash=filesep;

slashIdx=strfind(classFolder,slash);
class=classFolder(slashIdx(end)+1:end);
fileNames=getClassFilenames(fig,class);

% If there are no files, return an empty struct.
if isempty(fileNames)    
    classVar=struct([]);
    return;
end

% If there are files, load them all to the class variable. Each index of the struct is one instance of the class
for i=length(fileNames):-1:1 % Loop is backwards to pre-allocate memory for the classVar
    fileName=fileNames{i};

    % IN THE FUTURE MAYBE THERE SHOULD BE A TOGGLE FOR WHETHER TO USE JSON
    % OR .MAT FILES AS "GROUND TRUTH"? I FOUND THIS FEATURE TO BE ANNOYING
    % IN DEEPLABCUT THAT IT USED NON-HUMAN READABLE HDF5 FILES INSTEAD OF
    % MODIFIABLE CSV'S.
    fullPath=[classFolder slash fileName]; % Get the name of the json file that the settings are saved to.
       
    settingsStruct=loadJSON(fullPath);

    classVar(i)=settingsStruct;
end