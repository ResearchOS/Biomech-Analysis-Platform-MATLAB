function []=addSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: ADD A NEW SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

name=promptName('Enter Specify Trials condition name');
createSpecifyTrialsStruct(fig,name);

fillUITree_SpecifyTrials(fig);