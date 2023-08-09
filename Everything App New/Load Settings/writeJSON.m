function []=writeJSON(fullPath, json, date)

%% PURPOSE: WRITE A JSON TO FILE.

%% For saving the data into the GUI appdata 

try
    fig=evalin('base','gui');
catch
    fig=findall(0,'Name','pgui');
end

if exist('date','var')~=1
    date=datetime('now');
end

if isstruct(json)
    json.DateModified=date;
end

if ~isequal(fullPath(end-4:end),'.json')
    fullPath=[fullPath '.json'];
end

%% Format the linkage matrix to be written
if ~isstruct(json)
%     prettyJSON = getName(json); % Has to be before JSON gets formatted for the linkage matrix.
    jsonStr = formatLinkageMatrix(json,'write');
    uuid = 'Linkages';
%     prettyJSON = formatLinkageMatrix(prettyJSON, 'write');
%     [folder] = fileparts(fullPath);
%     fid = fopen([folder filesep 'PrettyLinkages.json'],'w');
%     fprintf(fid, '%s', prettyJSON);
%     fclose(fid);
else
    jsonStr=jsonencode(json,'PrettyPrint',true);
    uuid = json.UUID;
end

fid=fopen(fullPath,'w');
fprintf(fid,'%s',jsonStr);
fclose(fid);

setappdata(fig, uuid, json);