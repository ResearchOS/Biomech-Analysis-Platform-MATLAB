function []=addSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: ADD A NEW SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

name=promptName('Enter Specify Trials condition name');
createNewObject(false, 'SpecifyTrials', name, '', '', true); % Creates an abstract specify trials

fillUITree_SpecifyTrials(fig);