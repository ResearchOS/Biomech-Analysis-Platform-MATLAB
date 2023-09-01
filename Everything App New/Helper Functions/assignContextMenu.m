function []=assignContextMenu(node,handles)

%% PURPOSE: ASSIGN THE PROPER CONTEXT MENU TO THE CURRENT NODE. HOW TO REMOVE A SUBSET OF CONTEXT MENU ITEMS?

% fig=ancestor(node,'figure','toplevel');

% parent=getUITreeFromNode(node);
% uuid = node.NodeData.UUID;
% [type,~,instanceID] = deText(uuid);
% 
% if isempty(instanceID)
%     isInstance=false;
% else
%     isInstance=true;
% end

set(node,'ContextMenu',handles.Process.ContextMenuTop);

% The full list of context menu item names
% contextMenuNames = fieldnames(handles.Process.ContextMenu);

% Menu items that should always be present.
% alwaysKeepNames = {'CopyUUID','PasteUUID','Edit','SaveEdits','CopyToNew'}';
% currKeepNames = {};

% switch type
%     case 'PR'
%         if isInstance
%             currKeepNames = {'OpenMFile'};
%         end
%     case 'PG'
%         disp('test');
%     case 'VR'  
%     otherwise 
% 
% end
% 
% allKeepNames = [alwaysKeepNames; currKeepNames];
% for i=1:length(allKeepNames)
%     uimenu(newMenu,'Text',handles.Process.ContextMenu.(allKeepNames{i}).Text,...
%         'MenuSelectedFcn',handles.Process.ContextMenu.(allKeepNames{i}).MenuSelectedFcn);
% end
% 
% set(node,'ContextMenu',newMenu);