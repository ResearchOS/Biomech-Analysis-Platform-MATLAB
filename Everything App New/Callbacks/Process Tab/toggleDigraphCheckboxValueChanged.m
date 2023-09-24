function []=toggleDigraphCheckboxValueChanged(src,event)

%% PURPOSE: HIDE OR SHOW THE DIGRAPH & ASSOCIATED COMPONENTS

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

val = handles.Process.toggleDigraphCheckbox.Value;

%% Change visibility
% Change digraph visibility
handles.Process.digraphAxes.Visible = val;
handles.Process.prettyVarsCheckbox.Visible = val;

% Change queue & specify trials visibility
handles.Process.queueLabel.Visible = ~val;
handles.Process.queueUITree.Visible = ~val;
handles.Process.addSpecifyTrialsButton.Visible = ~val;
handles.Process.removeSpecifyTrialsButton.Visible = ~val;
handles.Process.editSpecifyTrialsButton.Visible = ~val;
handles.Process.allSpecifyTrialsUITree.Visible = ~val;
handles.Process.runButton.Visible = ~val;
handles.Process.sendEmailsCheckbox.Visible = ~val;

% Change view visibility
handles.Process.viewsDropDown.Visible = val;
handles.Process.editViewButton.Visible = val;
handles.Process.multiSelectButton.Visible = val;
handles.Process.addToViewButton.Visible = val;
handles.Process.removeFromViewButton.Visible = val;
handles.Process.successorsButton.Visible = val;
handles.Process.predecessorsButton.Visible = val;
handles.Process.predecessorsButton.Visible = val;
handles.Process.newViewButton.Visible = val;
handles.Process.archiveViewButton.Visible = val;

if ~val
    delete(handles.Process.digraphAxes.Children);
end

currTab=handles.Process.subtabCurrent.SelectedTab.Title;
if isequal(currTab,'Analysis')
    handles.Process.addToQueueButton.Visible = ~val;
    handles.Process.removeFromQueueButton.Visible = ~val;
else
    handles.Process.addToQueueButton.Visible = false;
    handles.Process.removeFromQueueButton.Visible = false;
end

%% Fill in the digraph. Placeholder for this, should probably happen elsewhere.
if ~val
    return; % Don't fill in the digraph if it's not visible!
end

Current_View = getCurrent('Current_View');
G = filterGraph(fig, Current_View);
renderGraph(fig, G); % Show the graph.