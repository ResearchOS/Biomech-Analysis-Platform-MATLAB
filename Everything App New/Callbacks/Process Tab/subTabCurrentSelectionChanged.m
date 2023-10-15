function []=subTabCurrentSelectionChanged(src,event)

%% PURPOSE: CHANGE VISIBILITY OF ASSIGN/UNASSIGN BUTTONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Process.subtabCurrent.SelectedTab.Title;

switch currTab
    case 'Analysis'
        varVis=false;
        showQueueButtons = true;
    case 'Group'        
        varVis=false; 
        showQueueButtons = true;
    case 'Function'
        varVis=true;
        showQueueButtons = true;
end

handles.Process.assignVariableButton.Visible=varVis;
handles.Process.unassignVariableButton.Visible=varVis;

handles.Process.assignFunctionButton.Visible=~varVis;
handles.Process.unassignFunctionButton.Visible=~varVis;

handles.Process.assignGroupButton.Visible=~varVis;
handles.Process.unassignGroupButton.Visible=~varVis;

if showQueueButtons && ~handles.Process.toggleDigraphCheckbox.Value
    handles.Process.addToQueueButton.Visible = true;
    handles.Process.removeFromQueueButton.Visible  = true;
else
    handles.Process.addToQueueButton.Visible = false;
    handles.Process.removeFromQueueButton.Visible  = false;
end