function [containerUUID, handle] = getContainer(src, fig)

%% PURPOSE: RETURN WHETHER THIS FUNCTION OR FUNCTION GROUP SHOULD BE ADDED TO AN ANALYSIS OR GROUP
% Determination based on which subtab I am currently on.

%% Provided a char UUID.
handles = getappdata(fig,'handles');
groupLabel = handles.Process.currentGroupLabel.Text;
groupSplitLabel = strsplit(groupLabel);
groupUUID = groupSplitLabel{2};

anUUID = getCurrent('Current_Analysis');

if ischar(src)
    links = loadLinks();
    [type] = deText(src);
    if isequal(type,'VR')

    end
    if ismember({type},{'PR','PG'})
        idx = ismember(links(:,1),src);
        pgIdx = idx & ismember(links(:,2),groupUUID);
        anIdx = idx & ismember(links(:,2),anUUID);
        groupInCurrentAn = ismember(links(:,1),groupUUID) & ismember(links(:,2),anUUID); % Make sure the group is part of the current analysis.
        % Unassigning if already has a container.
        if any(pgIdx) && any(groupInCurrentAn)
            containerUUID = groupUUID;
            handle = handles.Process.groupUITree;
        elseif any(anIdx)
            containerUUID = links(anIdx,2);
            handle = handles.Process.analysisUITree;
        else % Assigning, doesn't yet have a container
            container = handles.Process.subtabCurrent.SelectedTab.Title;
            switch container
                case 'Analysis'
                    containerUUID = anUUID;
                    handle = handles.Process.analysisUITree;
                case 'Group'
                    groupNode = handles.Process.analysisUITree.SelectedNodes;
                    containerUUID = groupNode.NodeData.UUID;
                    handle = handles.Process.groupUITree;
                otherwise

            end
        end
        return;
    end
end

%% Provided a graphics object handle.
% if ~ischar(src)
%     fig=ancestor(src,'figure','toplevel');
%     handles=getappdata(fig,'handles');
% 
%     if ~exist('container','var')
%         container = handles.Process.subtabCurrent.SelectedTab.Title;
%     end
%     switch container
%         case 'Analysis'
%             containerUUID = getCurrent('Current_Analysis');
%             handle = handles.Process.analysisUITree;
%         case 'Group'
%             groupNode = handles.Process.analysisUITree.SelectedNodes;
%             containerUUID = groupNode.NodeData.UUID;
%             handle = handles.Process.groupUITree;
%         otherwise
% 
%     end
% end