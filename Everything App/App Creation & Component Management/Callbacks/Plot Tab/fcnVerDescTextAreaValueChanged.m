function []=fcnVerDescTextAreaValueChanged(src,event)

%% PURPOSE: CHANGE THE DESCRIPTION FOR THE CURRENT FUNCTION VERSION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.plotFcnUITree.SelectedNodes;

if isempty(selNode)
    return;
end

desc=handles.Plot.fcnVerDescTextArea.Value;

plotName=selNode.Text;

Plotting=getappdata(fig,'Plotting');

Plotting.Plots.(plotName).Metadata.Description=desc;

% selNode.Tooltip=desc;

setappdata(fig,'Plotting',Plotting);