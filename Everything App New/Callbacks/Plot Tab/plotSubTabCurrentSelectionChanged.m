function []=plotSubTabCurrentSelectionChanged(src,event)

%% PURPOSE: CHANGE VISIBILITY OF ASSIGN/UNASSIGN BUTTONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Plot.subtabCurrent.SelectedTab.Title;

switch currTab
    case 'Plot'
        varVis=false;
    case 'Component'
        varVis=true;
    case 'Properties'
        varVis=false;
end

handles.Process.assignVariableButton.Visible=varVis;
handles.Process.unassignVariableButton.Visible=varVis;

if ismember(currTab,{'Properties'})
    varVis=~varVis; % So that no arrows appear.
end

handles.Plot.assignComponentButton.Visible=~varVis;
handles.Plot.unassignComponentButton.Visible=~varVis;

handles.Plot.assignPlotButton.Visible=~varVis;
handles.Plot.unassignPlotButton.Visible=~varVis;