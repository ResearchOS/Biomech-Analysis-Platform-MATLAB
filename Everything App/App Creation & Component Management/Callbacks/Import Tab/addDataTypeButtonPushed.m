function []=addDataTypeButtonPushed(src)

fig=ancestor(src,'figure','toplevel');

% Open a text box with the name of the new data type
dataType=inputdlg('Enter new data type to import');

% Ensure the entry is stored all in caps
dataType=upper(dataType);

% Add it to the list of items in the dropdown list
h=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
if contains(h.Items,dataType)
    disp([dataType ' Already Exists in Project ' getappdata(fig,'projectName')]);
    return;
else
    if length(h.Items)==1 && isequal(h.Items{1},'No Data Types to Import')
        h.Items=dataType;
    else
        h.Items=[h.Items dataType];
    end
    h.Value=dataType;
end

% Populate the text box with a '1A'
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
hText.Value='1A';

% Call the text field's ValueChangedFcn to write the new data type & method
% number & letter in to the allProjects.txt file
dataTypeImportMethodFieldValueChanged(src);