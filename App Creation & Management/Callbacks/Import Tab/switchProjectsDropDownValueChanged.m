function []=switchProjectsDropDownValueChanged(src)

%% PURPOSE: IF THE SELECTED PROJECT IN THE DROP DOWN CHANGED, THEN PROPAGATE THOSE CHANGES TO THE EDIT FIELDS IN THE IMPORT TAB.

data=src.Value;

fig=ancestor(src,'figure','toplevel');

% Set the project name field according to the current drop down selection
fig.Children.Children(1,1).Children(12,1).Value=data;

projectNameFieldValueChanged(fig.Children.Children(1,1).Children(12,1)); % Run the callback for the project name edit field value changed (input is project name field)