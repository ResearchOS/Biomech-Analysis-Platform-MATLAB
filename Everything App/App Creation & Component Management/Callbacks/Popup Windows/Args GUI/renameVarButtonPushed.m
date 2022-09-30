function []=renameVarButtonPushed(src,event)

%% PURPOSE: RENAME A VARIABLE ALREADY EXISTING IN FCN LIST BOX AND/OR ALL ARGS LIST BOX.
% ALSO PROPAGATE CHANGES INTO THE TEXT FILE, AND THE ARGS FILE IF IT EXISTS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

guiTab=getappdata(fig,'guiTab');
projectName=getappdata(fig,'projectName');
fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');

% 1. Get the current name of the selected variable
prevVarName=handles.fullNicknameEditField.Value;

% 2. Go into the text file and change its name in all functions in this guiTab, and in the 'All' (i.e. 'Unassigned') list.
% Need to get all group names within the current GUI tab (including Unassigned)
% Need to get all fcn names within each group name in the current GUI tab. (including Unassigned)
% Iterate over each one, changing the variable name but leaving everything else untouched.

% 3. Modify the args function file name and function declaration.

% 4. Change its display in the All and Fcn list boxes.