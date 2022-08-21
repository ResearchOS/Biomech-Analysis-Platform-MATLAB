function [splitsStruct]=addSplitToStruct(splitsStruct,selSplit,splitName,splitColor,splitCode)

if isempty(selSplit) % Top level
    splitsStruct.(splitName).Name=splitName;
    splitsStruct.(splitName).Color=splitColor;
    splitsStruct.(splitName).Code=splitCode;
    return;
end

for i=1:length(selSplit)
    splits=splits.SubSplitNames.(selSplit{i});
end