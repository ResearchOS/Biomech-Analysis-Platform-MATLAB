function []=changeName(src,event)

%% PURPOSE: CHANGE THE NAME (BUT NOT THE ID OR PSID) OF A PI OR PS STRUCT.
% ALSO CHANGES THE NAME EVERYWHERE IT IS LINKED.

return;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

if isequal(class(selNode.Parent),'matlab.ui.container.CheckBoxTree')
    uiTree=selNode.Parent;
else
    uiTree=selNode.Parent.Parent;
end

structClass=getClassFromUITree(uiTree);

text=selNode.Text;

[name, id, psid]=deText(text);

prevTextPI=[name '_' id];
piPrevPath=getClassFilePath(prevTextPI,structClass);
prevStructPI=loadJSON(piPrevPath);

newName=promptName('Enter the new name');
newTextPI=[newName '_' id];

% Change PI metadata
newStructPI=prevStructPI;
newStructPI.Name=newName;
newStructPI.Text=newTextPI;

% Save the new PI name
piNewPath=getClassFilePath(newTextPI, structClass);
writeJSON(piPrevPath,newStructPI); % Overwrite the existing file.
movefile(piPrevPath,piNewPath); % Rename the file.

%% Get the names of all links in PI struct. Need to change the name in all places.

%% Get the names of all PS versions of this PI file. Change the name in those files, and in all linked files.

%% Get the names of all links in this PS struct. Need to change the name in all places.