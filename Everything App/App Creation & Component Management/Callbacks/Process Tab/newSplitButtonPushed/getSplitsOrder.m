function [splitsOrder]=getSplitsOrder(selNode,rootTag)

% The selected split will always be at the end, and the root split will always be first.

if isempty(selNode)
    disp('Select a split first!');
    splitsOrder=[];
    return;
end

text=selNode.Text;
spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
% splitName=selNode.Text;
splitsOrder{1}=splitName;
currObj=selNode;
while ~isequal(currObj.Tag,rootTag) % Stop when the current object is the root object of the tree (i.e. top node or the tree itself)
%     currObj=selNode.Parent;
%     if isequal(currObj.Tag,rootTag)
%         break;
%     end
    
    currObj=currObj.Parent;
    if isequal(class(currObj),'matlab.ui.container.CheckBoxTree')
        break;
    end
    text=currObj.Text;
    spaceIdx=strfind(text,' ');
    splitName=text(1:spaceIdx-1);
%     splitName=currObj.Text;
    splitsOrder=[{splitName}; splitsOrder];
    
end