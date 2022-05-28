function []=addDataTypeButtonPushed(src)

fig=ancestor(src,'figure','toplevel');

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Need to enter the code path!');
    return;
end

if isempty(getappdata(fig,'dataPath'))
    beep;
    warning('Need to enter the data path!');
    return;
end

% Open a text box with the name of the new data type
dataType=inputdlg('Enter new data type to import');

if isempty(dataType)
    return;
end

% Ensure the entry is stored all in caps
dataType=upper(dataType);

% Add it to the list of items in the dropdown list
h=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
if ismember(dataType,h.Items)
    disp(['Data Type ''' dataType{1} ''' Already Exists in Project: ' getappdata(fig,'projectName')]);
    h.Value=dataType;
    dataTypeImportSettingsDropDownValueChanged(h);
    % Need to also change the method number & letter when this happens
    return;
else
    if length(h.Items)==1 && isequal(h.Items{1},'No Data Types to Import')
        h.Items=dataType;
        hTrialIDColHeaderDataTypes=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
        hTrialIDColHeaderDataTypes.Visible='on';
    else
        h.Items=sort([h.Items dataType]);
    end
    h.Value=dataType;
end

% Populate the text box with a '1A'
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
hText.Value='1A';

% Reset this to its original value
hTrialIDColHeaderDataTypesField=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
hTrialIDColHeaderDataTypesField.Value='Data Type: Trial ID Column Header';

% Call the text field's ValueChangedFcn to write the new data type & method
% number & letter in to the allProjects.txt file
dataTypeImportMethodFieldValueChanged(src);

% Call the dropdown's ValueChangedFcn to create data type checkboxes in the data load panel
dataTypeImportSettingsDropDownValueChanged(h);