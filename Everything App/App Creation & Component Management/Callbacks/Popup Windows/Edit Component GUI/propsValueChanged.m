function []=propsValueChanged(src,pgui)

%% PURPOSE: CHANGE THE PROPERTY DISPLAYED IN THE POPUP WINDOW TEXT AREA
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

propName=handles.propsList.Value;

props=handles.props;
% propNames=fieldnames(props);

% Manage the various property types to convert them to characters
var=props.(propName);
varText=convertVarToChar(var);

ta=handles.propTextArea;
ta.Value=varText;