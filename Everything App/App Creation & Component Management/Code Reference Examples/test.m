function []=test()

%% DOUBLE CLICK WITHIN A UI TREE NODE OBJECT.
clc;
global jtree;
set(groot,'Units','characters')
figure('Position',[200,200,400,400]);
root = uitreenode('v0', 'Datatypes', 'Datatypes', [], false);
root.add(uitreenode('v0', 'Potato', 'Potato', [], true));
root.add(uitreenode('v0', 'Tomato', 'Tomato', [], true));
root.add(uitreenode('v0', 'Carrot', 'Carrot', [], true));
[mtree,container] = uitree('v0', 'Root', root,'Position',[50,50,150,150]);
jtree = mtree.getTree;
% MousePressedCallback is not supported by the uitree, but by jtree
set(jtree, 'MousePressedCallback', @mousePressedCallback);
uiwait(gcf,2);
root2 = uitreenode('v0', 'Datatypes2', 'Datatypes2', [], false);
root2.add(uitreenode('v0', 'Carrot2', 'Carrot2', [], true));
root2.add(uitreenode('v0', 'Tomato2', 'Tomato2', [], true));
mtree.setRoot(root2);
%displ tthe root and its children
root=mtree.getRoot();
rootName = root.getName();
for i=0:root.getChildCount()-1
    childNode = root.getChildAt(i);
    childName = childNode.getName();
    disp(childName);
end
end

function mousePressedCallback(hTree, eventData) %,additionalVar)
% if eventData.isMetaDown % right-click is like a Meta-button
% if eventData.getClickCount==2 % how to detect double clicks
persistent x;
global jtree;
if isempty(x)
    x=0;
end
x=x+1;
clickX = eventData.getX;
clickY = eventData.getY;
treePath = jtree.getPathForLocation(clickX, clickY);
if ~isempty(treePath)
    nr=eventData.getClickCount();
    disp([num2str(x) ': click count:' num2str(nr)]);
    % check if the checkbox was clicked
    node = treePath.getLastPathComponent;
    nodeValue = node.getValue;
else
    disp('you clicked outside the tree')
end
end % function mousePressedCallback