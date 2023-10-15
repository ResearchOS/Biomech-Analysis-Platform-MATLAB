function [] = confirmAndDeleteObject(uuid, node, doConfirm)

%% PURPOSE: ASK THE USER TO CONFIRM THAT THEY WANT TO DELETE THE OBJECT. THEN DELETE IT.
% ALSO CHECK IF IT'S LINKED TO ANYTHING, AND IF SO, ASK THEM TO CONFIRM AGAIN.

global globalG;

if nargin==2
    doConfirm=true;
end

if doConfirm
    a = questdlg(['UUID: ' uuid ', Name: ' getName(uuid)],'Are you sure you want to delete this?','No');
    if ~isequal(a,'Yes')
        return;
    end

    hasEdges = false;
    edgesIdx = ismember(globalG.Edges.EndNodes(:,1),uuid) | ismember(globalG.Edges.EndNodes(:,2),uuid);
    numEdges = sum(edgesIdx);
    if numEdges>0
        hasEdges = true;
    end

    if hasEdges
        disp([globalG.Edges.EndNodes(edgesIdx,:) getName(globalG.Edges.EndNodes(edgesIdx,1)) getName(globalG.Edges.EndNodes(edgesIdx,2))]);
        a = questdlg(['UUID: ' uuid ', Name: ' getName(uuid) ' Has Active Edges','Are you sure you want to delete this?'],'No');
        if ~isequal(a,'Yes')
            return;
        end
    end
end

% 1. Delete the project node in database and digraph.
% Automatically deletes associated edges.
deleteObject(uuid);

% 2. Delete the node in the GUI.
delete(node);