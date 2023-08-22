function [data]=loadJSON(str, runCheck)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.
% str is either a path or a UUID

try
    fig=evalin('base','gui');
catch
    fig=findall(0,'Name','pgui');
end

if isempty(fig)
    error('No gui found');
end

if exist('runCheck','var')~=1
    runCheck = true; % Helpful for testing.
end

% Provided a UUID, not a file path.
if ~contains(str,filesep) && ~contains(str,'.json') % UUID
    fullPath = getJSONPath(str);
    uuid = str;
else % Path
    fullPath = str;
    [~,uuid]=fileparts(fullPath);
end

data = getappdata(fig, uuid);

% Testing only %
% if ~isequal(uuid,'Linkages')
%     data='';
% end
% End testing only %

%% If data not in appdata, read the json file as unformatted char
setTheAppData = true;
loadData = true;
loadedDates = getappdata(fig,'loadedDates');
if ~isempty(data)
    loadData = false;
    runCheck = false; % It's been checked previously. For max speed, don't re-do this.
    setTheAppData = false;
    file = dir(fullPath);
    if isUUID(uuid) && isfield(loadedDates,uuid) && loadedDates.(uuid) < max([datetime(file.date) datetime(data.DateModified)])
        loadData = true;
        setTheAppData = true;
    end
end

if loadData
    try
        fid=fopen(fullPath);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');
    catch e
        error('File not found!');
    end

    % Convert json to struct
    data=jsondecode(jsonStr);
end
if ~isstruct(data) && setTheAppData
    data = formatLinkageMatrix(data, 'read');
end

% Check that this struct contains all required fields. If it does not,
% default values are inserted. EXCEPT for UUID field, which throws an
% error.
if runCheck
    data = checkFields(data);
end

%% Now that the data has been loaded, 
if setTheAppData    
    setappdata(fig,uuid,data);    
end

loadedDates.(uuid) = datetime('now');
setappdata(fig,'loadedDates',loadedDates);