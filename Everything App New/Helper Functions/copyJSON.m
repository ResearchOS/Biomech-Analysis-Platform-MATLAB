function []=copyJSON(sourcePath,destPath)

%% PURPOSE: COPY A JSON FILE FROM ONE PATH TO ANOTHER

source=loadJSON(sourcePath);

date=datetime('now');

source.DateCreated=date;
source.DateModified=date;

% For Process only, remove the date last ran.
if isfield(source,'DateLastRan')
    source=rmfield(source,'DateLastRan');
end

[folder,name,ext]=fileparts(destPath);

name=fileNames2Texts(name);
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