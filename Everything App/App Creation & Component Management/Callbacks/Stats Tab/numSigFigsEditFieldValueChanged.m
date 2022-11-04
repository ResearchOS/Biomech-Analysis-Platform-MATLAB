function []=numSigFigsEditFieldValueChanged(src,event)

%% PURPOSE: SPECIFY HOW MANY SIGNIFICANT FIGURES TO ROUND THE DATA TO
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

pubTableName=handles.Stats.pubTablesUITree.SelectedNodes.Text;

numSigFigs=handles.Stats.numSigFigsEditField.Value;

if numSigFigs<=0
    handles.Stats.numSigFigsEditField.Value=Stats.PubTables.(pubTableName).SigFigs;
    disp('Must be >= 1!');
    return;
end

Stats.PubTables.(pubTableName).SigFigs=numSigFigs;

setappdata(fig,'Stats',Stats);