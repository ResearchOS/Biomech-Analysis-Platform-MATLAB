function [] = updateFieldValues()

%% PURPOSE: UPDATE THE VALUE OF EACH FIELD OF THE NEW VARIABLE OBJECTS USING THE OLD OBJECTS.
clc;
oldPath = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/TEST PGUI COMMON PATH (DELETE SOON)';
currPath = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath';

% Settings for this run
% class = 'Variable';
% absFields = {'IsHardCoded','Level'};
% instFields = {'HardCodedValue'};

class = 'Process';
% absFields = {'InputVariablesNamesInCode','OutputVariablesNamesInCode','Level','MFileName'};
instFields = {};

slash = filesep;

oldAbsPath = [oldPath slash class];
currAbsPath = [currPath slash class];

oldInstPath = [oldAbsPath slash 'Implementations'];
currInstPath = [currAbsPath slash 'Instances'];

%% ALWAYS DO THE ABSTRACT FIRST!!! HELPS THE INSTANCES.
% modifyStructs(class, oldAbsPath, currAbsPath, absFields);
modifyStructsInst(class, oldInstPath, currInstPath, instFields);

end

function [] = modifyStructsInst(class, oldPath, currPath, fields)

%% PURPOSE: 
currListing = dir(currPath);
currNames = {currListing.name};
currNames = fileNames2Texts(currNames);

oldListing = dir(oldPath);
oldNames = {oldListing.name};
prevCount = 0;

load('idMaps_abstract_fcn.mat','idMaps');

for i=1:length(currNames)
    name = currNames{i};

    if length(name)<=2 || ~isequal(name(1:2),className2Abbrev(class))
        continue; % Folder or something.
    end

    [type, abstractID, instanceID] = deText(name);

    % Process only
    idxNums = find(contains(idMaps(:,1),abstractID)==1);
    if isempty(idxNums)
        continue; % No need to rename.
    end
    oldNamesToChange = idMaps(idxNums,1);

    % Update the old files.
    oldNewFilePaths = {};
    newNewFilePaths = {};
    for j=1:length(oldNamesToChange)   
        instNames = oldNames(contains(oldNames,oldNamesToChange{j}(1:end-5))); % Get the names of all instances of this abstract ID
        for k = 1:length(instNames)
            oldFile = [oldPath filesep instNames{k}];
            instNames{k} = strrep(instNames{k}, abstractID, idMaps{idxNums(j),2}(3:end)); % Change each one.
            newFile = [oldPath filesep instNames{k}];
            % Change the file name. 
            try
                movefile(oldFile, newFile);
            catch e
            end
            instanceID = instNames{k}(end-7:end-5);
            oldNewFilePaths = [oldNewFilePaths; getJSONPath(genUUID(className2Abbrev(class), abstractID, instanceID))];
            newNewFilePaths = [newNewFilePaths; getJSONPath(genUUID(className2Abbrev(class), idMaps{idxNums(j),2}(3:end), instanceID))];
        end
    end

    % Update the new files.  
    for j = 1:length(oldNewFilePaths)
        try
            movefile(oldNewFilePaths{j}, newNewFilePaths{j});
        catch e
        end
    end

    continue;

    oldIdxNum = find(contains(oldNames, abstractID) & contains(oldNames, instanceID)==1);
    currOldNames = oldNames(oldIdxNum);    
    if length(currOldNames)>1        
        % If multiple instances have the same abstract ID (one of which has changed), and instance ID, distinguish between them.
        for j=1:length(currOldNames)
            underscoreIdx = strfind(currOldNames{j},'_');
            prefix = currOldNames{j}(1:underscoreIdx(end)-1);
            if any(contains(idMaps(:,1),prefix))
                oldIdxNum = oldIdxNum(j);
                currOldNames = oldNames(oldIdxNum);
                break;
            end
        end
    end

    if isempty(currOldNames)
        continue; % No instances of this in the new folder.
    end

    assert(length(currOldNames)==1);

    oldName = currOldNames{1};
    oldOldFileName = [oldPath filesep oldName];    

    idx = contains(idMaps(:,1),abstractID);

    % The object has had its abstract ID changed.      
    if any(idx)
        newAbstractID = idMaps{idx,2}(3:end);
        % Change the old file name.        
        newOldFileName = [oldPath filesep oldName(1:length(oldName)-15) newAbstractID oldName(length(oldName)-8:end)]; % New filename for the old objects.
        movefile(oldOldFileName, newOldFileName);

        % Change the new file name (matching old abstract ID & instance ID) to have the new abstract ID
        oldNewFileName = getJSONPath(genUUID(className2Abbrev(class), abstractID, instanceID)); % Old filename for the new objects.
        newNewFileName = getJSONPath(genUUID(className2Abbrev(class), newAbstractID, instanceID)); % New filename for the new objects.
        movefile(oldNewFileName, newNewFileName);
        continue;
        oldStruct = loadJSON(newOldFileName, false);
        currStruct = loadJSON(newNewFileName);
    else
        continue;
        oldStruct = loadJSON(oldOldFileName, false);
        currStruct = loadJSON(name);
    end

    for k = 1:length(fields)
        currStruct.(fields{k}) = oldStruct.(fields{k});
    end

    writeJSON(getJSONPath(currStruct), currStruct);

end

end








function [] = modifyStructs(class, oldPath, currPath, fields)

currListing = dir(currPath);
currNames = {currListing.name};
currNames = fileNames2Texts(currNames);

oldListing = dir(oldPath);
oldNames = {oldListing.name};
prevCount = 0;
% currCount = 0;

isInst = false;
if contains(currPath,'Instances')
    isInst = true;
    load('idMaps_abstract.mat','idMaps');
end

for i=1:length(currNames)
    name = currNames{i};

    if length(name)<=2 || ~isequal(name(1:2),className2Abbrev(class))
        continue; % Folder or something.
    end

    [type, abstractID, instanceID] = deText(name);
    
    oldIdx = contains(oldNames, abstractID);
    if isInst
        oldIdx = oldIdx & contains(oldNames, instanceID);
    end

    if ~any(oldIdx)
        continue;
    end

    oldFileNames = cell(sum(oldIdx),1);
    oldIdxNums = find(oldIdx==1);
    for j=1:length(oldIdxNums)
        oldFileNames{j} = [oldPath filesep oldNames{oldIdxNums(j)}];
    end

    needsFix = false;   
    % Check if needs fixing based on whether it's instance or abstract.    
    if (sum(oldIdx)>1 && ~isInst)
        needsFix = true;
        oldIdx = find(oldIdx==1);
        b = oldNames(oldIdx)';
        disp(b);          

%         if length(b)>2
%             disp(b)
%         end
        
        if ~isInst % For abstract ID's only. 
            newAbstractIDs=cell(size(oldIdx));
            for j = 1:length(oldIdx)
                prevCount = prevCount+1;
                newAbstractIDs{j} = createID_Abstract(class);
                idMaps(prevCount,:) = {b{j} genUUID(class, newAbstractIDs{j})};

                % Rename the file
                duplFileName = [oldPath filesep oldNames{oldIdx(j)}];
                oldFileNames{j} = [oldPath filesep oldNames{oldIdx(j)}(1:end-11) newAbstractIDs{j} '.json'];
                movefile(duplFileName, oldFileNames{j});
            end
        else % For instance ID's only.       
            prevCount = prevCount+1;
            % Get the corresponding abstract ID from the idMaps
            idMapIdx = contains(idMaps(:,1),abstractID);
            abstractName = idMaps{idMapIdx,1}(1:end-5);

            % Isolate only the instances of the abstract variable that was
            % modified.
            modifyIdx = contains(b,abstractName);
            if ~any(modifyIdx)
                needsFix = false;                
            else
                b = b(modifyIdx);
            end
            oldIdx = find(contains(oldNames,b)==1);
            for j=1:length(b)
                b{j} = [b{j}(1:length(abstractName)-6) idMaps{idMapIdx,2}(3:end) b{j}(length(abstractName)+1:end)];
            end

            % Rename the (potentially multiple) instance files   
            oldFileNames = cell(length(oldIdx),1);
            for j=1:length(oldIdx)
                duplFileName = [oldPath filesep oldNames{oldIdx(j)}];
                oldFileNames{j} = [oldPath filesep b{j}];
                movefile(duplFileName, oldFileNames{j});
            end

        end        
    end

    continue; % Don't update any fields.

    % Update the values for the abstract files, and the (potentially multiple) instance files
    for j=1:length(oldFileNames)
        oldFileName = oldFileNames{j};
        oldStruct = loadJSON(oldFileName, false);        

        if needsFix
            newAbstractID = newAbstractIDs{j};
            if ~isInst
                currStruct = createNewObject(isInst, class, oldStruct.Text, newAbstractID, '', true);
            else
                currStruct = createNewObject(isInst, class, oldStruct.Text, oldFileName(end-14:end-9), oldFileName(end-7:end-5), true);
            end
        else
            currStruct = loadJSON(name);
        end

        for k = 1:length(fields)
            currStruct.(fields{k}) = oldStruct.(fields{k});
        end

        writeJSON(getJSONPath(currStruct), currStruct);

    end

end

if ~isInst
    save idMaps_abstract_fcn.mat idMaps;
end

end