function []=changeFieldname(classFolder,origName,newName)

%% PURPOSE: RENAME A FIELD TO A NEW NAME, INSTANTIATE A NEW FIELD, OR DELETE A FIELD FROM ALL CLASS INSTANCES IN A FOLDER.

[folderPath,className]=fileparts(classFolder);
filenames=getClassFilenames(className,folderPath);

texts=fileNames2Texts(filenames);

for i=1:length(texts)

    text=texts{i};
    fullPath=getClassFilePath(text,className);
    struct=loadJSON(fullPath);
    if isempty(newName) % Delete the origName field
        if isfield(struct,origName)
            struct=rmfield(struct,origName);
        end
    elseif isempty(origName) % Create the newName field
        if ~isfield(struct,newName)
            struct.(newName)={};
        else
            dbstop if error;
            error('Field already exists');
        end
    else % Replace the origName field with the newName field
        if isfield(struct,origName)
            struct.(newName)=struct.(origName);
            struct=rmfield(struct,origName);
        else
            disp(['Field ' origName ' does not exist']);
        end
    end

    writeJSON(fullPath,struct);

end

disp('All files adjusted');