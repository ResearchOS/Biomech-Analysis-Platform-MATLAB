function [] =toggleVisibility_Digraph(handles)

%% PURPOSE: TOGGLE ALL GRAPHICS OBJECTS RELATED TO THE DIGRAPH.

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

handles.Process.addToQueueButton.Visible = ~val;
handles.Process.removeFromQueueButton.Visible = ~val;

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

% currTab=handles.Process.subtabCurrent.SelectedTab.Title;
% if isequal(currTab,'Analysis')

% else
%     handles.Process.addToQueueButton.Visible = false;
%     handles.Process.removeFromQueueButton.Visible = false;
% end