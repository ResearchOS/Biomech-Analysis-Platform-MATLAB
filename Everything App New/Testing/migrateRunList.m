%% PURPOSE: MOVE THE RUN LIST FOR THE PROCESS GROUPS TO THE RUNLIST AND THE NEW FORMAT.

path = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/ProcessGroup/Instances';

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
    if ~isfield(struct,'ExecutionListNames')
        continue; % New format already
    end
    execNames = struct.ExecutionListNames;
    types = struct.ExecutionListTypes;

    if isempty(execNames)
        continue;
    end

    runlist = cell(size(execNames));
    for j = 1:length(execNames)
        runlist{j,1} = [className2Abbrev(types{j}) execNames{j}(end-9:end)];
    end

    struct.RunList = runlist;
    writeJSON(getJSONPath(struct), struct);

end