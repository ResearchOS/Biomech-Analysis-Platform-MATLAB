function []=propsValueChanged(src,pgui)

%% PURPOSE: CHANGE THE PROPERTY DISPLAYED IN THE POPUP WINDOW TEXT AREA
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

propName=handles.propsList.Value;

props=getappdata(fig,'props');

% Manage the various property types to convert them to characters
propClass=class(props.(propName));

if isequal(propClass,'matlab.graphics.primitive.Text')
    var=props.(propName).String;
else
    var=props.(propName);
end
varText=convertVarToChar(var);

ta=handles.propTextArea;
ta.Value=varText;