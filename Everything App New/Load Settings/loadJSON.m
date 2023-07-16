function [data]=loadJSON(str, runCheck)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

if exist('runCheck','var')~=1
    runCheck = true; % Helpful for testing.
end

% Provided a UUID, not a file path.
if ~contains(str,filesep)
    fullPath = getJSONPath(str);
else
    fullPath = str;
end
    
Store_Settings = getCurrent('Store_Settings');

%% For retrieving the previously loaded data from the GUI appdata
if Store_Settings
    try
        fig=evalin('base','gui');
    catch
        fig=findall(0,'Name','pgui');
    end
    [~,uuid]=fileparts(fullPath);
    data=getappdata(fig,uuid);
    if ~isempty(data)
        return; % Returns empty if the variable is not found in
    end
end

% Read the json file as unformatted char
try
    fid=fopen(fullPath);
    raw=fread(fid,inf);
    fclose(fid);
    str=char(raw');
catch e
    error('File not found!');
end

% Convert json to struct
data=jsondecode(str);

if ~isstruct(data)
    data = formatLinkageMatrix(data, 'read');
end

% Check that this struct contains all required fields. If it does not,
% default values are inserted. EXCEPT for UUID field, which throws an
% error.
if runCheck
    data = checkFields(data);
end

%% Now that the data has been loaded, 
if exist('fig','var')==1 && Store_Settings 
    setappdata(fig,uuid,data);
end