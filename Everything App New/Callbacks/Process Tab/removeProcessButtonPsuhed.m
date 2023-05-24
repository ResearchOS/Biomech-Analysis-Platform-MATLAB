function []=removeProcessButtonPsuhed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allProcessUITree;

processNode=uiTree.SelectedNodes;

if isempty(processNode)
    return;
end

slash=filesep;

processPath=getClassFilePath(processNode.Text,'Process');
processStruct=loadJSON(processPath);

[folder,name]=fileparts(processPath);

archiveFolder=[folder slash 'Archive'];
mkdir(archiveFolder);
archivePath=[archiveFolder slash name '.json'];

processStruct.Archived=true;
processStruct.Checked=false;
processStruct.Visible=false;

writeJSON(processPath,processStruct);

movefile(processPath,archivePath);

%% Remove the node from the UI tree
selectNeighborNode(processNode);
delete(processNode);

allProcessUITreeSelectionChanged(fig);