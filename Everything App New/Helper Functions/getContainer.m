function [containerUUID] = getContainer(tab)

%% PURPOSE: RETURN WHETHER THIS FUNCTION OR FUNCTION GROUP SHOULD BE ADDED TO AN ANALYSIS OR GROUP
% Determination based on which subtab I am currently on.

%% Provided a char UUID.
fig=ancestor(tab,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab = tab.Title;
switch currTab
    case 'Analysis'   
        containerUUID = getCurrent('Current_Analysis');
        % uiTree = handles.Process.analysisUITree;  
        % [~,list] = getUITreeFromNode(uiTree.SelectedNodes);
        % pgUUID = list(contains(list,'PG'));
        % if ~isempty(pgUUID)
        %     pgUUID = pgUUID{1};
        %     % Ask the user if they want to put the selected object in the
        %     % current group, or the current analysis.
        %     a = questdlg('Add to analysis or group?','Select container','Analysis','Group','Cancel','Analysis');            
        %     if isequal(a,'Group')
        %         containerUUID = pgUUID;
        %     elseif isequal(a,'Analysis')
        % 
        %     else
        %         return; % Canceled or closed out.
        %     end
        % end
    case 'Group'
        containerUUID = getCurrentProcessGroup(fig);
        % Check if there is a group selected in the analysis UI tree
        % anTreeNode = handles.Process.allAnalysesUITree.SelectedNodes;
        % [~, list] = getUITreeFromNode(anTreeNode);
        % pgIdx = find(contains(list,'PG')==1);
        % containerUUID = '';
        % if ~isempty(pgIdx)
        %     containerUUID = list(min(pgIdx));
        % end
        % uiTree = handles.Process.groupUITree;
end




















% groupLabel = handles.Process.currentGroupLabel.Text;
% groupSplitLabel = strsplit(groupLabel);
% groupUUID = groupSplitLabel{2};
% 
% anUUID = getCurrent('Current_Analysis');
% 
% if ischar(src)
%     links = loadLinks();
%     [type] = deText(src);
%     if isequal(type,'VR')
% 
%     end
%     if ismember({type},{'PR','PG'})
%         idx = ismember(links(:,1),src);
%         pgIdx = idx & ismember(links(:,2),groupUUID);
%         anIdx = idx & ismember(links(:,2),anUUID);
%         groupInCurrentAn = ismember(links(:,1),groupUUID) & ismember(links(:,2),anUUID); % Make sure the group is part of the current analysis.
%         % Unassigning if already has a container.
%         if any(pgIdx) && any(groupInCurrentAn)
%             containerUUID = groupUUID;
%             handle = handles.Process.groupUITree;
%         elseif any(anIdx)
%             containerUUID = links(anIdx,2);
%             handle = handles.Process.analysisUITree;
%         else % Assigning, doesn't yet have a container
%             container = handles.Process.subtabCurrent.SelectedTab.Title;
%             switch container
%                 case 'Analysis'
%                     containerUUID = anUUID;
%                     handle = handles.Process.analysisUITree;
%                 case 'Group'
%                     groupNode = handles.Process.analysisUITree.SelectedNodes;
%                     containerUUID = groupNode.NodeData.UUID;
%                     handle = handles.Process.groupUITree;
%                 otherwise
% 
%             end
%         end
%         return;
%     end
% end
