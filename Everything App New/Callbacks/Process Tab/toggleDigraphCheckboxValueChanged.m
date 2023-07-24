function []=toggleDigraphCheckboxValueChanged(src,event)

%% PURPOSE: HIDE OR SHOW THE DIGRAPH & ASSOCIATED COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

val = src.Value;

% Change digraph visibility
handles.Process.digraphAxes.Visible = val;

% Change queue & specify trials visibility
handles.Process.queueLabel.Visible = ~val;
handles.Process.queueUITree.Visible = ~val;
handles.Process.addSpecifyTrialsButton.Visible = ~val;
handles.Process.removeSpecifyTrialsButton.Visible = ~val;
handles.Process.editSpecifyTrialsButton.Visible = ~val;
handles.Process.allSpecifyTrialsUITree.Visible = ~val;
handles.Process.runButton.Visible = ~val;