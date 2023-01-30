function []=copyToNewPS(src,event)

%% PURPOSE: COPY THE SPECIFIED PS STRUCT TO A NEW PS STRUCT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

uiTree=selNode.Parent.Parent;

class=getClassFromUITree(uiTree);

% Create new PSID for the copy
[name,id]=deText(text);
psid=createPSID([name '_' id], class);

% Create the copy
newText=[name '_' id '_' psid];
psPath=getClassFilePath(text, class);
newPathPS=getClassFilePath(newText, class);
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

if isequal(class,'Variable')
    psStruct.InputToProcess={};
    psStruct.OutputOfProcess={};
end

writeJSON(newPathPS,psStruct);

% Create new uitreenode
uitreenode(selNode.Parent,'Text',newText,'ContextMenu',handles.Process.psContextMenu);