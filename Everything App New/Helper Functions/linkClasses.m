function [fromStruct, toStruct]=linkClasses(src, fromStruct, toStruct)

%% PURPOSE: LINK TWO CLASS INSTANCES TOGETHER.
% Linked FROM the fromStruct TO the toStruct (forward link)

% arguments
%     src
%     fromStruct (1,1) mustBeAStruct(fromStruct,["struct"]);
%     toStruct (1,1) mustBeAStruct;
% end

fig=ancestor(src,'figure','toplevel');

fromText=fromStruct.Text;
fullPathFrom=getClassFilePath(fromText, fromStruct.Type, fig);

toText=toStruct.Text;
fullPathTo=getClassFilePath(toText, toStruct.Type, fig);

%% Assign fromStruct to toStruct
fwdField=['ForwardLinks_' fromStruct.Type];
if ~isfield(toStruct,fwdField)
    toStruct.(fwdField)={fromText};
else
    toStruct.(fwdField)=unique([toStruct.(fwdField); {fromText}],'stable');
end

%% Assign toStruct to fromStruct
backField=['BackwardLinks_' toStruct.Type];
if ~isfield(fromStruct,backField)
    fromStruct.(backField)={toText};
else
    fromStruct.(backField)=unique([fromStruct.(backField); {toText}],'stable');
end

writeJSON(fullPathFrom, fromStruct);
writeJSON(fullPathTo, toStruct);