function [fromStruct, toStruct]=linkClasses(fromStruct, toStruct)

%% PURPOSE: LINK TWO CLASS INSTANCES TOGETHER.
% Linked FROM the fromStruct TO the toStruct (forward link)

fromText=fromStruct.Text;
fullPathFrom=getClassFilePath(fromText, fromStruct.Class);

toText=toStruct.Text;
fullPathTo=getClassFilePath(toText, toStruct.Class);

%% Assign fromStruct to toStruct
backField=['BackwardLinks_' fromStruct.Class];
if ~isfield(toStruct,backField)
    toStruct.(backField)={fromText};
else
    toStruct.(backField)=unique([toStruct.(backField); {fromText}],'stable');
end

%% Assign toStruct to fromStruct
fwdField=['ForwardLinks_' toStruct.Class];
if ~isfield(fromStruct,fwdField)
    fromStruct.(fwdField)={toText};
else
    fromStruct.(fwdField)=unique([fromStruct.(fwdField); {toText}],'stable');
end

writeJSON(fullPathFrom, fromStruct);
writeJSON(fullPathTo, toStruct);