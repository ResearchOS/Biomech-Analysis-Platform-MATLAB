function []=pubTablesUITreeSelectionChanged(src,event)

%% PURPOSE: CHANGE UI ELEMENTS IN RESPONSE TO SELECTING DIFFERENT PUBLICATION TABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.pubTablesUITree.SelectedNodes)
    return;
end

currPubTable=handles.Stats.pubTablesUITree.SelectedNodes.Text;

numSigFigs=Stats.PubTables.(currPubTable).SigFigs;

handles.Stats.numSigFigsEditField.Value=numSigFigs;
