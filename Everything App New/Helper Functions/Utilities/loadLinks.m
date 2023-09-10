function [links, hardCodedVR]=loadLinks(list)

%% PURPOSE: JOIN AND LOAD THE LINKAGE TABLES RESPONSIBLE FOR CONNECTING THE PROCESSING FUNCTIONS TO EACH OTHER VIA VARIABLES.
global conn;

if isempty(list)
    links = cell(0,3);
    return;
end

% Only the contained UUIDs ('PR') should be loaded, because only they are in the PR_VR & VR_PR tables.
if size(list,2)==2
    list = list(:,1);
end

prIdx = contains(list,'PR'); % All processing functions together (from all groups in current analysis).
list = list(prIdx,:); % Isolate the rows that have processing functions, not groups in groups.

% Links format: Nx3 cell array
% Column 1: PR outputting the VR (empty if the VR is hard-coded)
% Column 2: VR connecting the two PR's
% Column 3: PR with the VR as an input (empty if VR is not an input anywhere)
sqlquery = ['SELECT PR_VR.PR_ID PR_UUID_Out, VR_PR.VR_ID VR_UUID, VR_PR.PR_ID PR_UUID_In FROM VR_PR LEFT JOIN PR_VR ON VR_PR.VR_ID = PR_VR.VR_ID;'];
allLinks = fetch(conn, sqlquery);
allLinks = fillmissing(allLinks,'constant',"");
links = cellstr(table2cell(allLinks));

% Add the VR from the LG
lgIdx = contains(list,'LG');
if any(lgIdx)
    lgUUIDs = list(lgIdx);
    lgStr = getCondStr(lgUUIDs);
    sqlquery = ['SELECT VR_ID, LG_ID FROM LG_VR WHERE LG_ID IN ' lgStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);

    % If any LG & VR found.
    if ~isempty(t)
        if ~iscell(t.VR_ID)
            t.VR_ID = {t.VR_ID};
            t.LG_ID = {t.LG_ID};
        end

        % Put the logsheet where the VR is an input, and there is no
        % output.
        for i=1:length(t.VR_ID)
            vrIdx = ismember(links(:,2),t.VR_ID{i});
            assert(all(cellfun(@isempty, links(vrIdx,1))));
            links(vrIdx,1) = t.LG_ID(i);
        end
    end
end

idx = ismember(links(:,1),list) | ismember(links(:,3),list);

hardCodedVRidx = cellfun(@isempty, links(:,1));
hardCodedVR = links(hardCodedVRidx,2);

links(~idx,:) = [];