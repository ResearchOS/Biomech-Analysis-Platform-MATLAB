function [splitsOrder]=getSplitsOrder(selNode)

if isempty(selNode)
    disp('Select a split first!');
    splitsOrder=[];
    return;
end
splitName=selNode.Text;
splitsOrder{1}=splitName;
currObj=selNode.Parent;
while ~isequal(class(currObj),'matlab.ui.container.CheckBoxTree')
    splitName=currObj.Text;
    splitsOrder=[{splitName}; splitsOrder];
    currObj=currObj.Parent;
end