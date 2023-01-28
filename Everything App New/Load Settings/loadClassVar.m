function [classVar]=loadClassVar(classFolder)

%% PURPOSE: GO THROUGH ALL OF THE FILES IN THE CLASS'S FOLDER AND LOAD THEM INTO MEMORY IF THEY HAVE 'VISIBLE' SET TO 1
slash=filesep;

slashIdx=strfind(classFolder,slash);
class=classFolder(slashIdx(end)+1:end);
fileNames=getClassFilenames(class);

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

    %% Testing only. Merge unlike structs
    a=fieldnames(settingsStruct);

    if exist('classVar','var')
        b=fieldnames(classVar);
        for j=1:length(b) % Add classVar fields to settingsStruct

            if ~isfield(settingsStruct,(b{j}))
                settingsStruct.(b{j})=[];
            end

        end

        for j=1:length(a) % Add settingsStruct fields to classVar

            if ~isfield(classVar,(a{j}))
                classVar(i).(a{j})=[];
            end

        end
    end

    classVar(i)=settingsStruct;
end