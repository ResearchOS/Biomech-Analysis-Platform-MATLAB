function []=addSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: ADD A NEW SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% name=promptName('Enter Specify Trials condition name');
struct = createNewObject(false, 'SpecifyTrials', '', '', '', true); % Creates an abstract specify trials

if isempty(struct)
    return;
end

Current_Analysis = getCurrent('Current_Analysis');
linkObjs(struct.UUID, Current_Analysis);

fillUITree_SpecifyTrials(fig);