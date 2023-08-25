function []=writeJSON(struct, date)

%% PURPOSE: WRITE A JSON TO FILE.

global conn;

if exist('date','var')~=1
    date=datetime('now');
end

if isstruct(struct)
    struct.Date_Modified=date;
end

%% Format the linkage matrix to be written
% if ~isstruct(struct)
% %     prettyJSON = getName(json); % Has to be before JSON gets formatted for the linkage matrix.
%     jsonStr = formatLinkageMatrix(struct,'write');
%     uuid = 'Linkages';
% %     prettyJSON = formatLinkageMatrix(prettyJSON, 'write');
% %     [folder] = fileparts(fullPath);
% %     fid = fopen([folder filesep 'PrettyLinkages.json'],'w');
% %     fprintf(fid, '%s', prettyJSON);
% %     fclose(fid);
% else
    % jsonStr=jsonencode(json,'PrettyPrint',true);
uuid = struct.UUID;
% end

[type, abstractID, instanceID] = deText(uuid);
if isempty(instanceID)
    isInstance = false;
else
    isInstance = true;
end
tablename = getTableName(type, isInstance);
sqlquery = struct2SQL(tablename, struct);
exec(conn, sqlquery);