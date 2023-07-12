function []=addVariableButtonPushed(src,event)

%% PURPOSE: CREATE A NEW VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

variableName=promptName('Enter Variable Name');

if isempty(variableName)
    return;
end

varStruct = createNewObject(false, 'Variable', variableName, '', '', true);

addNewNode(handles.Process.allVariablesUITree, varStruct.UUID, varStruct.Text);

figure(fig);