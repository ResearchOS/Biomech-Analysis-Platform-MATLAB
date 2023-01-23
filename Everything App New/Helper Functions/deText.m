function [name, id, psid]=deText(text)

%% PURPOSE: BREAK DOWN THE "TEXT" FIELD INTO ITS CONSTITUENT "NAME", "ID", AND "PSID" COMPONENTS.

splitText=strsplit(text,'_');
underscoreIdx=strfind(text,'_');

% Project-specific
if length(splitText{end-1})==6 && length(splitText{end})==3
    psid=splitText{end};
    id=splitText{end-1};
    name=text(1:underscoreIdx(end-1)-1);
elseif length(splitText{end-1})==6 % Project-independent
    psid='';
    id=splitText{end};
    name=text(1:underscoreIdx(end)-1);
end