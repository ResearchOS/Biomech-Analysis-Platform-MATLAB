function []=toggleDigraphCheckboxValueChanged(src,event)

%% PURPOSE: HIDE OR SHOW THE DIGRAPH & ASSOCIATED COMPONENTS

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

containerUUID = getCurrent('Current_Analysis');
list = getUnorderedList(containerUUID);
links = loadLinks(list);
G = linkageToDigraph(links);

renderGraph(fig, G); % Show the graph.