function []=openSpecifyTrialsGUI(src,uiTree)

%% PURPOSE: OPEN A POPUP WINDOW TO EDIT THE SPECIFY TRIALS CONDITION.

pgui=ancestor(src,'figure','toplevel');
pguiHandles=getappdata(pgui,'handles');

%% Create all of the components.