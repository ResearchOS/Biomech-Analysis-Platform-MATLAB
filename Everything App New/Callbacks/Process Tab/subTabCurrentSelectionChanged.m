function []=subTabCurrentSelectionChanged(src,event)

%% PURPOSE: CHANGE VISIBILITY OF ASSIGN/UNASSIGN BUTTONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Process.subtabCurrent.SelectedTab.Title;

switch currTab
    case 'Analysis'
        varVis=false;
    case 'Group'        
        varVis=false;        
    case 'Function'
        varVis=true;
end

handles.Process.assignVariableButton.Visible=varVis;
handles.Process.unassignVariableButton.Visible=varVis;

handles.Process.assignFunctionButton.Visible=~varVis;
handles.Process.unassignFunctionButton.Visible=~varVis;

handles.Process.assignGroupButton.Visible=~varVis;
handles.Process.unassignGroupButton.Visible=~varVis;