function []=assignVarButtonPushedAxesLims(src,event)

%% PURPOSE: ASSIGN A VARIABLE TO THE CURRENT AXES LIMITS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.varsUITree.SelectedNodes)
    return;
end

axLims=getappdata(fig,'axLims');

dim=handles.dimDropDown.Value;

selNode=handles.varsUITree.SelectedNodes;

if isequal(selNode.Parent,handles.varsUITree)
    disp('Select the split, not the variable!');
    return;
end

splitName=selNode.Text;

spaceIdx=strfind(splitName,' ');
split=splitName(spaceIdx(end)+2:end-1);

varName=selNode.Parent.Text;

fullName=[varName ' (' split ')'];

axLims.(dim).VariableNames=[axLims.(dim).VariableNames; {fullName}];
axLims.(dim).SubvarNames=[axLims.(dim).SubvarNames; {''}];

setappdata(fig,'axLims',axLims);

makeAxLimsSelVarNodes(fig);