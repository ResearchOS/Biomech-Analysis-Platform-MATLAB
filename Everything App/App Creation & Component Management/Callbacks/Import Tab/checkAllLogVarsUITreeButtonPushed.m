function []=checkAllLogVarsUITreeButtonPushed(src,event)

%% PURPOSE: Select all column headers in log var UI tree

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

for i=1:length(handles.Import.logVarsUITree.Children)

    headerName=handles.Import.logVarsUITree.Children(i).Text;
    headerNameVar=genvarname(headerName);

    if ~isempty(NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType) && ...
            ~isempty(NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject)

        handles.Import.logVarsUITree.CheckedNodes=[handles.Import.logVarsUITree.CheckedNodes; handles.Import.logVarsUITree.Children(i)];

    else

        disp(['Logsheet variable missing metadata, not checked: ' headerName]);

    end

end

if ~getappdata(fig,'isRunLog')
    desc='Check all variables in Import tab with previously entered metadata';
    updateLog(fig,desc);
end