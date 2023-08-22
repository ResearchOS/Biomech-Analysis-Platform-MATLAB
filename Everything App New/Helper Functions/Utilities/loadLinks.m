function [links, linksFilePath]=loadLinks()

%% PURPOSE: LOAD THE LINKAGE MATRIX

linksFolder = [getCommonPath() filesep 'Linkages'];
linksFilePath = [linksFolder filesep 'Linkages.json'];

links = loadJSON(linksFilePath);