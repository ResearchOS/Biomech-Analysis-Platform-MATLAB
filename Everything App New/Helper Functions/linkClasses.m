function [fromStruct, toStruct]=linkClasses(src, fromStruct, toStruct)

%% PURPOSE: LINK TWO CLASS INSTANCES TOGETHER.
% Linked FROM the fromStruct TO the toStruct (forward link)

fig=ancestor(src,'figure','toplevel');

fromText=fromStruct.Text;
fullPathFrom=getClassFilePath(fromText, fromStruct.Type, fig);

toText=toStruct.Text;
fullPathTo=getClassFilePath(toText, toStruct.Type, fig);

%% Assign fromStruct to toStruct
backField=['BackwardLinks_' fromStruct.Type];
if ~isfield(toStruct,backField)
    toStruct.(backField)={fromText};
else
    toStruct.(backField)=unique([toStruct.(backField); {fromText}],'stable');
end

%% Assign toStruct to fromStruct
fwdField=['ForwardLinks_' toStruct.Type];
if ~isfield(fromStruct,fwdField)
    fromStruct.(fwdField)={toText};
else
    fromStruct.(fwdField)=unique([fromStruct.(fwdField); {toText}],'stable');
end

writeJSON(fullPathFrom, fromStruct);
writeJSON(fullPathTo, toStruct);