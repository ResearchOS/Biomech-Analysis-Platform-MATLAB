function []=switchProjectsDropDownValueChanged(src)

%% PURPOSE: IF THE SELECTED PROJECT IN THE DROP DOWN CHANGED, THEN PROPAGATE THOSE CHANGES TO THE EDIT FIELDS IN THE IMPORT TAB.

data=src.Value;

fig=ancestor(src,'figure','toplevel');

% Set the project name field according to the current drop down selection
h=findobj(fig,'Type','uieditfield','Tag','ProjectNameField');
h.Value=data;

projectNameFieldValueChanged(h); % Run the callback for the project name edit field value changed (input is project name field)