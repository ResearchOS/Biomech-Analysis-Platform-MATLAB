function [fromStruct, toStruct]=unlinkClasses(src, fromStruct, toStruct)

%% PURPOSE: REMOVE A LINK BETWEEN TWO CLASSES

fig=ancestor(src,'figure','toplevel');

fromText=fromStruct.Text;
fullPathFrom=getClassFilePath(fromText, fromStruct.Type, fig);

toText=toStruct.Text;
fullPathTo=getClassFilePath(toText, toStruct.Type, fig);

%% Remove fromStruct from toStruct
backField=['BackwardLinks_' fromStruct.Type];
if isfield(toStruct,backField)
    idx=ismember(fromText,toStruct.(backField));
    toStruct.(backField)(idx)=[];
end

%% Remove toStruct from fromStruct
fwdField=['ForwardLinks_' toStruct.Type];
if isfield(fromStruct,fwdField)
    idx=ismember(toText,fromStruct.(fwdField));
    fromStruct.(fwdField)(idx)=[];
end

writeJSON(fullPathFrom, fromStruct);
writeJSON(fullPathTo, toStruct);