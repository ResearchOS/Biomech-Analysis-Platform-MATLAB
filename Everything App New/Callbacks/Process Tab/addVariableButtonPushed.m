function []=addVariableButtonPushed(src,event)

%% PURPOSE: CREATE A NEW VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

variableName=promptName('Enter Variable Name');

if isempty(variableName)
    return;
end

createNewObject(false, 'Variable', variableName, '', '', true);

searchTerm=getSearchTerm(handles.Process.variablesSearchField);

fillUITree(fig,'Variable',handles.Process.allVariablesUITree, ...
    searchTerm,handles.Process.sortVariablesDropDown);

figure(fig);