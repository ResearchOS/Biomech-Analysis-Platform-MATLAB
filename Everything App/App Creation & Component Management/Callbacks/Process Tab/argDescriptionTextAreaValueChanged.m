function []=argDescriptionTextAreaValueChanged(src,argDesc,varGUIName)

%% PURPOSE: STORE THE MODIFIED DESCRIPTION TO THE APPROPRIATE VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
if exist('argDesc','var')~=1
    argDesc=handles.Process.argDescriptionTextArea.Value;
    runLog=true;
else
    handles.Process.argDescriptionTextArea.Value=argDesc;
    runLog=false;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

% projectSettingsVars=whos('-file',projectSettingsMATPath);
% projectSettingsVarNames={projectSettingsVars.name};
% 
% if ~ismember('VariableNamesList',projectSettingsVarNames)
%     disp(['No variables present yet!']);
%     return;
% end

VariableNamesList=getappdata(fig,'VariableNamesList');
if isempty(VariableNamesList)
    disp('No variables present yet!');
    return;
end
% load(projectSettingsMATPath,'VariableNamesList');

if runLog
    selNode=handles.Process.varsListbox.SelectedNodes;
    varGUIName=selNode.Text;
else
    handles.Process.varsListbox.SelectedNodes=findobj(handles.Process.varsListbox,'Text',varGUIName);
    selNode=handles.Process.varsListbox.SelectedNodes;
end
if contains(selNode.Text,' (')
    selNode=selNode.Parent; % If this is a split node that is selected, instead select the variable node itself.
    varGUIName=selNode.Text;
end

if ~iscell(varGUIName)
    varGUIName={varGUIName};
end

% if length(varGUIName)>1
%     beep;
%     disp('To store an argument description only one variable can be selected!');
%     return;
% end
% splitName=handles.Process.splitsUITree.SelectedNodes.Text;

%% Find the row of the VariableNamesList pertaining to the current variable and split name. Then, change its description.
% varIdx=ismember(VariableNamesList.GUINames,varGUIName) & ismember(VariableNamesList.SplitNames,splitName);
varIdx=ismember(VariableNamesList.GUINames,varGUIName); % & ismember(VariableNamesList.SplitNames,splitName);

try
    assert(sum(varIdx)==1); % Ensure that it is unique
catch
    handles.Process.argDescriptionTextArea.Value='';
    disp(['Variable ' varNameInGUI ' Not Found in VariableNamesList! Check the settings file']);
    return;
end

VariableNamesList.Descriptions{varIdx}=argDesc;

% save(projectSettingsMATPath,'VariableNamesList','-append');
setappdata(fig,'VariableNamesList',VariableNamesList);

if runLog
    desc='Changed argument description';
    updateLog(fig,desc,argDesc,varGUIName);
end