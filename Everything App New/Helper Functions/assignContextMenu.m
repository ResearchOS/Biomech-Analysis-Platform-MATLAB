function []=assignContextMenu(node,handles)

%% PURPOSE: ASSIGN THE PROPER CONTEXT MENU TO THE CURRENT NODE.

parent=getUITreeFromNode(node);

[~,~,psid]=deText(node.Text);

if isempty(psid)
    isPS=false;
else
    isPS=true;
end

switch parent
    case handles.Process.allProcessUITree
        if isPS
            node.ContextMenu=handles.Process.psContextMenuNoMFile;
        else
            node.ContextMenu=handles.Process.commonContextMenu;
        end
    case handles.Process.groupUITree
        if isPS
            node.ContextMenu=handles.Process.psContextMenu;
        else
            error('What happened?');
        end
    case handles.Process.functionUITree
%         if isPS
            node.ContextMenu=handles.Process.psContextMenu;
%         else
%             error('What happened?');
%         end
    case handles.Plot.allPlotsUITree
        if isPS
            node.ContextMenu=handles.Process.psContextMenu;
        else
            node.ContextMenu=handles.Process.commonContextMenuNoMFile;
        end
    case handles.Plot.componentUITree
        if isPS
            node.ContextMenu=handles.Process.psContextMenu;
        else
            error('What happened?');
        end
    case handles.Plot.allComponentsUITree
        if isPS
            node.ContextMenu=handles.Process.psContextMenu;
        else
            node.ContextMenu=handles.Process.commonContextMenu;
        end
    otherwise % No M files associated with this class
        if isPS
            node.ContextMenu=handles.Process.psContextMenuNoMFile;
        else
            node.ContextMenu=handles.Process.commonContextMenuNoMFile;
        end
end