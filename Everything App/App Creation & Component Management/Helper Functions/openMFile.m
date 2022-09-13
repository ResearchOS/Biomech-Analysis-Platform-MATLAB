function []=openMFile(src,currPoint,isIn)

%% PURPOSE: OPEN THE .M FILE FOR THE SELECTED FUNCTION
% Inputs:
% src: Graphics object of the pgui (graphics object)
% currPoint: The current place in the processing map figure that the person
% double clicked (1 x 2 double)
% isIn: 1 if opening a function, 0 if opening a variable .m file

%% NOTE: NEED TO CONVERT THE GUI NAME TO THE DEFAULT NAME! RIGHT NOW, THIS WILL NOT WORK FOR VARS WITH GUI NAMES DIFFERENT THAN DEFAULT SAVE NAMES!

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Process.fcnArgsUITree.SelectedNodes;
if isempty(selNode)
    return;
end

if isequal(class(selNode.Parent),'matlab.ui.container.CheckBoxTree') % Open the function
    name=selNode.Text;
    filePath=[getappdata(fig,'codePath') 'Processing Functions' slash name '.m'];
elseif contains(selNode.Text,' (') % Check if hard-coded variable exists. If so, open it.
    name=selNode.Text;
    splitCode=name(end-3:end-1);
    filePath=[getappdata(fig,'codePath') 'Hard-Coded Variables' slash name(1:end-6) '_' splitCode '.m'];
end

if exist(filePath,'file')==2
    edit(filePath);
end