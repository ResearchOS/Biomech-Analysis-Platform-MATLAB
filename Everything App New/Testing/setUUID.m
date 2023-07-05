root = getCommonPath();
addUUID(root);

function []=addUUID(root)

%% PURPOSE: ADD THE UUID FIELD TO EACH OF THE OBJECTS

listing = dir(root);
names = {listing.name};
dirIdx = [listing.isdir];
objTypes = className2Abbrev('list');

for i=1:length(names)
    name=names{i};
    if name(1)=='.'
        continue; % Remove . and .. and hidden folders
    end
    if isequal(name,'Linkages')
        continue;
    end
    if dirIdx(i)
        addUUID([listing(i).folder filesep name]);
        continue;
    end

    if isequal(name(end-4:end),'.json')
        name=name(1:end-5); % Remove the ".json"
    else
        continue;
    end

    underscoreIdx = strfind(name,'_');

    struct = loadJSON(name);
    struct.UUID = name;
    writeJSON(getJSONPath(name),struct);

end

end