function []=copyToNewPS(src,event)

%% PURPOSE: COPY THE SPECIFIED PS STRUCT TO A NEW PS STRUCT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

psToPITree=false; % If a PS tree node is selected, the new node should be created in the corresponding PI tree.
uiTree=selNode.Parent.Parent;
parentNode=selNode.Parent;
if ~isequal(class(uiTree),'matlab.ui.container.CheckBoxTree')
    uiTree=selNode.Parent;
    psToPITree=true;
end

structClass=getClassFromUITree(uiTree);

% Create new PSID for the copy
[name,id]=deText(text);
psid=createPSID([name '_' id], structClass);

% Create the copy
newText=[name '_' id '_' psid];
psPath=getClassFilePath(text, structClass);
newPathPS=getClassFilePath(newText, structClass);
copyfile(psPath,newPathPS);

% Modify the copy
psStruct=loadJSON(newPathPS);
date=datetime('now');
psStruct.DateCreated=date;
psStruct.DateModified=date;
psStruct.Text=newText;
psStruct.ID=psid;
psStruct.OutOfDate=true;

% Remove prior links
fldNames=fieldnames(psStruct);
fldNamesLinks=fldNames(contains(fldNames,'Links_'));

for i=1:length(fldNamesLinks)
    psStruct.(fldNamesLinks{i})={};
end

if isequal(structClass,'Variable')
    psStruct.InputToProcess={};
    psStruct.OutputOfProcess={};
end

writeJSON(newPathPS,psStruct);

% In case the new node should not be created in the current UI tree
if psToPITree
    switch uiTree
        case handles.Process.groupUITree
            uiTree=handles.Process.allProcessUITree;
    end

    % Find the proper PS node in the new PI UI tree
    piText=[name '_' id];
    piNodesText={uiTree.Children.Text};
    piNodeIdx=ismember(piNodesText,piText);

    newNode=uitreenode(uiTree.Children(piNodeIdx),'Text',newText);
    assignContextMenu(newNode,handles);
else
    % Create new uitreenode
    newNode=uitreenode(selNode.Parent,'Text',newText);
    assignContextMenu(newNode,handles);
end

