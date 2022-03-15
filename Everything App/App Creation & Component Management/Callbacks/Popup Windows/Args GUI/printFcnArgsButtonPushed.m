function []=printFcnArgsButtonPushed(src,event)

%% PURPOSE: PRINT THE CURRENT SELECTION OF FUNCTION ARGS TO THE COMMAND WINDOW FOR COPYING AND PASTING INTO CODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currVals=sort(handles.fcnListBox.Value);

% Inputs
inputStr='{';
for i=1:length(currVals)

    inputStr=[inputStr '''' currVals{i} '''' ','];

end
inputStr=[inputStr(1:end-1) '}']; % Remove the final comma

% Outputs
outputStr='';
for i=1:length(currVals)

    outputStr=[outputStr currVals{i} ','];

end
outputStr=outputStr(1:end-1);

disp('Inputs: ');
disp(inputStr);
disp(char(13));
disp('Outputs:')
disp(outputStr);