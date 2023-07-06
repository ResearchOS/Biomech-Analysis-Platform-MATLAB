function []=assignContextMenu(node,handles)

%% PURPOSE: ASSIGN THE PROPER CONTEXT MENU TO THE CURRENT NODE.

parent=getUITreeFromNode(node);
uuid = node.NodeData.UUID;
[~,~,instanceID] = deText(uuid);

if isempty(instanceID)
    isInstance=false;
else
    isInstance=true;
end

set(node,'ContextMenu',handles.Process.ContextMenuTop);

switch parent
    case handles.Process.allProcessUITree
        if isInstance
            remIdx = [];
        else
            remIdx = [];
        end
    case handles.Process.groupUITree
        if isInstance
            remIdx = [];
        else
            error('What happened?');
        end
    case handles.Process.functionUITree
        remIdx = [];
    case handles.Plot.allPlotsUITree
        if isInstance
            remIdx = [];
        else
            remIdx = [];
        end
    case handles.Plot.componentUITree
        if isInstance
            remIdx = [];
        else
            error('What happened?');
        end
    case handles.Plot.allComponentsUITree
        if isInstance
            remIdx = [];
        else
            remIdx = [];
        end
    otherwise % No M files associated with this class
        if isInstance
            remIdx = [];
        else
            remIdx = [];
        end
end

% node.ContextMenu.Children(remIdx) = [];