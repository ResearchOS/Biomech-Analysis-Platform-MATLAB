%% PURPOSE: PROGRAMMATICALLY CHANGE THE VARIABLE ID'S IN THE PROCESS FUNCTION JSON FILES TO THE NEW FORMAT.

path = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/Process/Instances';

listing = dir(path);
names = {listing.name};
dirIdx = [listing.isdir];

for i=1:length(names)
    name = names{i};
    if name(1)=='.'
        continue;
    end

    if dirIdx(i)
        continue;
    end

    if isequal(name(end-4:end),'.json')
        name = name(1:end-5);
    else
        continue;
    end

    struct = loadJSON(name);
    fldNames = {'InputVariables','OutputVariables'};
    for j=1:length(fldNames)
        fldName = fldNames{j};
        vars = struct.(fldName);
        for k = 1:length(vars)
            currVars = vars{k};
            for l = 2:length(currVars)
%                 underscoreIdx = strfind(currVars{l}, '_');
%                 underscoreIdx = underscoreIdx(end-1);
                currVars{l} = ['VR' currVars{l}(end-9:end)];
            end
            vars{k} = currVars;
        end
        struct.(fldName) = vars;
    end

    writeJSON(getJSONPath(struct), struct);

end