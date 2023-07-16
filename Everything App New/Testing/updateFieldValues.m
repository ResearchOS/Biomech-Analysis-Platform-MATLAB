function [] = updateFieldValues()

%% PURPOSE: UPDATE THE VALUE OF EACH FIELD USING THE OLD OBJECTS.
clc;
oldPath = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/TEST PGUI COMMON PATH (DELETE SOON)';
currPath = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath';

% Settings for this run
class = 'Variable';
absFields = {'IsHardCoded','Level'};
instFields = {'HardCodedValue'};

slash = filesep;

oldAbsPath = [oldPath slash class];
currAbsPath = [currPath slash class];

oldInstPath = [oldAbsPath slash 'Instances'];
currInstPath = [currAbsPath slash 'Instances'];

modifyStructs(oldAbsPath, currAbsPath, absFields);
modifyStructs(oldInstPath, currInstPath, instFields);

end

function [] = modifyStructs(oldPath, currPath, fields)
%% Iterate over items

currListing = dir(currPath);
currNames = {currListing.name};
currNames = fileNames2Texts(currNames);

oldListing = dir(oldPath);
oldNames = {oldListing.name};
% oldNames = fileNames2Texts(oldNames);

for i=1:length(currNames)
    name = currNames{i};

    if length(name)<=2 || ~isequal(name(1:2),'VR')
        continue; % Folder or something.
    end

    [type, abstractID, instanceID] = deText(name);

    idx = contains(oldNames,abstractID);

    if ~any(idx)
        continue;
    end

    assert(sum(idx)==1);
    oldNames(idx)

    oldStruct = loadJSON([oldPath filesep oldNames{idx}], false);
    currStruct = loadJSON(name);

    for j = 1:length(fields)
        currStruct.(fields{j}) = oldStruct.(fields{j});
    end

    writeJSON(getJSONPath(currStruct), currStruct);

end

end