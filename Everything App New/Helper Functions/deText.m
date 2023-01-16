function [name, id, psid]=deText(text)

%% PURPOSE: BREAK DOWN THE "TEXT" FIELD INTO ITS CONSTITUENT "NAME", "ID", AND "PSID" COMPONENTS.

splitText=strsplit(text,'_');

name=splitText{1};

id=splitText{2};

if length(splitText)==3
    psid=splitText{3};
else
    psid='';
end