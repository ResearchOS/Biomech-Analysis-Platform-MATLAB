function [classVar]=loadClassVar(classFolder)

%% PURPOSE: GO THROUGH ALL OF THE FILES IN THE CLASS'S FOLDER AND LOAD THEM INTO MEMORY
slash=filesep;

slashIdx=strfind(classFolder,slash);
class=classFolder(slashIdx(end)+1:end);
fileNames=getClassFilenames(class);

% If there are no files, return an empty struct.
if isempty(fileNames)    
    classVar=struct([]);
    return;
end

[~,uuids] = fileparts(fileNames);
if ischar(uuids)
    uuids = {uuids};
end
classVarFields = {'Class', 'Text', 'UUID'}; % Only loads these fields from the struct. Ensures that all objects will always return a similar struct.
for i=length(uuids):-1:1 % Loop is backwards to pre-allocate memory for the classVar
    fileName=uuids{i};
           
    settingsStruct=loadJSON(fileName);
    allFields = fieldnames(settingsStruct);
    fldsToRemove = allFields(~ismember(allFields,classVarFields));
    settingsStruct=rmfield(settingsStruct,fldsToRemove);
    classVar(i) = settingsStruct;

end