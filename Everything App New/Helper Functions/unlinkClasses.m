function [fromStruct, toStruct]=unlinkClasses(src, fromStruct, toStruct)

%% PURPOSE: REMOVE A LINK BETWEEN TWO CLASSES

% arguments
%     src
%     fromStruct (1,1) mustBeAStruct;
%     toStruct (1,1) mustBeAStruct;
% end

fig=ancestor(src,'figure','toplevel');

fromText=fromStruct.Text;
fullPathFrom=getClassFilePath(fromText, fromStruct.Type, fig);

toText=toStruct.Text;
fullPathTo=getClassFilePath(toText, toStruct.Type, fig);

%% Remove fromStruct from toStruct
fwdField=['ForwardLinks_' fromStruct.Type];
if isfield(toStruct,fwdField)
    idx=ismember(fromText,toStruct.(fwdField));
    toStruct.(fwdField)(idx)=[];
end

%% Remove toStruct from fromStruct
backField=['BackwardLinks_' toStruct.Type];
if isfield(fromStruct,backField)
    idx=ismember(toText,fromStruct.(backField));
    fromStruct.(backField)(idx)=[];
end

writeJSON(fullPathFrom, fromStruct);
writeJSON(fullPathTo, toStruct);