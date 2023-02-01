function []=assignVersion(piStruct, verStruct)

%% PURPOSE: ASSIGN A VERSION TO A PROJECT-INDEPENDENT OBJECT.

piStruct.Versions=[piStruct.Versions; {verStruct.Text}];

saveClass(piStruct.Class, piStruct);