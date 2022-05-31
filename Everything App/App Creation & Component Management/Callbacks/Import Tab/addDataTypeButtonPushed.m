function []=addDataTypeButtonPushed(src,event)

%% PURPOSE: CREATE A NEW DATA TYPE (I.E. GROUP) IN THE FUNCTIONS UITREE BOX. ALSO SAVE IT TO PROJECT-SPECIFIC SETTINGS FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');
FcnSettingsStruct=getappdata(fig,'FcnSettingsStruct');

% 1. Prompt for the name of the new data type
isOKName=0; % Initialize that the new project name is not a valid MATLAB variable name.
while isOKName==0
    dataTypeName=inputdlg('Enter the new data type name','New Data Type Name');

    if isempty(dataTypeName) || isempty(dataTypeName{1})
        return; % Pressed Cancel, or did not enter anything.
    end

    dataTypeName=dataTypeName{1};

    if isvarname(dataTypeName)
        isOKName=1;
    else
        disp(['New data type creation was unsuccessful. Name must be valid MATLAB variable name, like this: ' genvarname(dataTypeName)]);
    end

end

% Check for duplicates
if ismember(dataTypeName,FcnSettingsStruct.Import.DataTypes)
    beep;
    disp(['Data type ' dataTypeName ' already exists!']);
    return;
end

% 2. Create UI tree parent node in the Functions list box.
fcnUITree=handles.Import.functionsUITree; % Isolate UI tree object
uitreenode(fcnUITree,'Text',dataTypeName);

% 3. Save the data type name to the project-specific settings file.
if length(FcnSettingsStruct.Import.DataTypes)==1 && isempty(FcnSettingsStruct.Import.DataTypes{1})
    FcnSettingsStruct.Import.DataTypes={dataTypeName};
else
    FcnSettingsStruct.Import.DataTypes=[FcnSettingsStruct.Import.DataTypes; {dataTypeName}]; % Add to the list of all of the data types
end
FcnSettingsStruct.Import.FcnUITree.(dataTypeName)=struct(); % Set up the UI tree structure to prepare for its children

% 4. Store the new data type
setappdata(fig,'FcnSettingsStruct',FcnSettingsStruct); % Store it back to the structure
save(getappdata(fig,'projectSettingsMATPath'),'FcnSettingsStruct','-append'); % Save it to the file.