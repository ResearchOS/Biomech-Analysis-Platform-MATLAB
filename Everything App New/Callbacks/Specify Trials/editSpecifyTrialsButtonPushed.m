function []=editSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: OPEN A GUI POPUP WINDOW TO EDIT THE SELECTED CONDITION.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab=src.Parent.Title;

specifyTrialsUITree=handles.(tab).allSpecifyTrialsUITree;

openSpecifyTrialsGUI(fig,specifyTrialsUITree)