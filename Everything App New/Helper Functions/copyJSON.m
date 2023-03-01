function []=copyJSON(sourcePath,destPath)

%% PURPOSE: COPY A JSON FILE FROM ONE PATH TO ANOTHER

source=loadJSON(sourcePath);

date=datetime('now');

source.DateCreated=date;
source.DateModified=date;

[folder,name,ext]=fileparts(destPath);

[name,id,psid]=deText(name);

if isempty(psid)
    text=[name '_' id];
%     id=id;
else
    text=[name '_' id '_' psid];
    id=psid;
end

source.Text=text;
source.ID=id;

writeJSON(destPath,source);