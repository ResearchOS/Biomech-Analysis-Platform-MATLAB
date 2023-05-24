function [name, id, psid]=deText(text)

%% PURPOSE: BREAK DOWN THE "TEXT" FIELD INTO ITS CONSTITUENT "NAME", "ID", AND "PSID" COMPONENTS.

openParensIdx=strfind(text,'(');
if ~isempty(openParensIdx)
    text=text(openParensIdx+1:end);
end

if ~isempty(text) && isequal(text(end),')')
    text=text(1:end-1);
end

% underscoreIdx is only empty if the current text is an argument
if isempty(text)
    name='';
    id='';
    psid='';
    return;
end

splitText=strsplit(text,'_');
underscoreIdx=strfind(text,'_');

if isempty(underscoreIdx)
    name=text;
    id='';
    psid='';
    return;
end

% Project-specific
if length(splitText{end-1})==6 && length(splitText{end})==3
    psid=splitText{end};
    id=splitText{end-1};
    name=text(1:underscoreIdx(end-1)-1);
elseif length(splitText{end})==6 % Project-independent
    psid='';
    id=splitText{end};
    name=text(1:underscoreIdx(end)-1);
else
    name=text;
    id='';
    psid='';
end