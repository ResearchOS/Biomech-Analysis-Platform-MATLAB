function []=writeJSON(fullPath, json, date)

%% PURPOSE: WRITE A JSON TO FILE.

%% For saving the data into the GUI appdata

rootSettingsFile=getRootSettingsFile;
load(rootSettingsFile,'Store_Settings');    

if exist('date','var')~=1
    date=datetime('now');
end

json.DateModified=date;

if Store_Settings
    try
        fig=evalin('base','gui');
    catch
        fig=findall(0,'Name','pgui');
    end
    [~,fileName]=fileparts(fullPath);
    underscoreIdx=strfind(fileName,'_');
    if ~isempty(underscoreIdx)
        text=fileName(underscoreIdx(1)+1:end); % Remove the class prefix
    else
        text=fileName;
    end
    % Maybe check here if there are any duplicate texts because they're not currently split by class?
    setappdata(fig,text,json);
end

if ~isequal(fullPath(end-4:end),'.json')
    fullPath=[fullPath '.json'];
end

% Format the linkage matrix to be written
if isfield(json,'RunList') && length(fieldnames(data))==1
    json = formatLinkageMatrix(json,'write');
end
json=jsonencode(json,'PrettyPrint',true);

fid=fopen(fullPath,'w');
fprintf(fid,'%s',json);
fclose(fid);