function []=addImportFcnButtonPushed(src,event)

%% PURPOSE: CREATE A NEW IMPORT FUNCTION WHEN THE BUTTON IS CLICKED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');
FcnSettingsStruct=getappdata(fig,'FcnSettingsStruct');

% 1. Prompt for the name of the new import function
isOKName=0; % Initialize that the new function name is not a valid MATLAB variable name.
while isOKName==0
    fcnName=inputdlg('Enter the new function name','New Function Name');

    if isempty(fcnName) || isempty(fcnName{1})
        return; % Pressed Cancel, or did not enter anything.
    end

    fcnName=fcnName{1};

    if isvarname(fcnName)
        isOKName=1;
    else
        disp(['New function creation was unsuccessful. Name must be valid MATLAB variable name, like this: ' genvarname(fcnName)]);
    end

end

% Check for duplicates
if ismember(fcnName,[FcnSettingsStruct.Import.FcnUITree.All; FcnSettingsStruct.Process.FcnUITree.All; FcnSettingsStruct.Plot.FcnUITree.All])
    beep;
    disp(['A function named ' fcnName ' already exists!']);
    return;
end

fcnUITree=handles.Import.functionsUITree; % Isolate UI Tree object

%% Make function node under 'All'
allFcnNode=findobj(fcnUITree.Children,'Tag','All_P');
if isempty(allFcnNode)
    allFcnNode=uitreenode(fcnUITree,'Text','All','Tag',['All_P']); % Ending with '_P' to indicate that this is a parent node.
end

uitreenode(allFcnNode,'Text',fcnName,'Tag',[fcnName '_C']); % Ending with '_C' to indicate that this is a child node.

if length(FcnSettingsStruct.Import.FcnUITree.All)==1 && isempty(FcnSettingsStruct.Import.FcnUITree.All{1})
    FcnSettingsStruct.Import.FcnUITree.All={fcnName};
else
    FcnSettingsStruct.Import.FcnUITree.All=[FcnSettingsStruct.Import.FcnUITree.All; {fcnName}];
end

%% Save & store
save(getappdata(fig,'projectSettingsMATPath'),'FcnSettingsStruct','-append');
setappdata(fig,'FcnSettingsStruct',FcnSettingsStruct);