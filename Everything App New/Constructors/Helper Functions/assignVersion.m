function [piStruct]=assignVersion(piStruct, verStruct)

%% PURPOSE: ASSIGN A VERSION TO A PROJECT-INDEPENDENT OBJECT.

if isfield(piStruct,'Versions')
    piStruct.Versions=[piStruct.Versions; {verStruct.Text}];
else
    piStruct.Versions={verStruct.Text};
end

saveClass(piStruct.Class, piStruct);