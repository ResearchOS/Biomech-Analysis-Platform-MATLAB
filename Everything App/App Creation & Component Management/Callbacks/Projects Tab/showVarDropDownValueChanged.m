function []=showVarDropDownValueChanged(src,varName)

%% PURPOSE: CHANGE THE VARIABLE NAME TO DISPLAY

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('varName','var')~=1
    runLog=true;
    varName=handles.Projects.showVarDropDown.Value;
else
    runLog=false;
    handles.Projects.showVarDropDown.Value=varName;
end

% if isequal(varName,'NonFcnSettingsStruct')
%     handles.Projects.saveVarButton.Visible=true;
% else
%     handles.Projects.saveVarButton.Visible=false;
% end

if runLog
    desc='Changed the dropdown to show a settings variable';
    updateLog(fig,desc,varName);
end

