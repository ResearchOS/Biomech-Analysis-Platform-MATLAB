function []=convertVarHardDynamicValueChanged(src,event)

%% PURPOSE: TURN A DYNAMIC VARIABLE INTO A HARD-CODED VARIABLE, AND GENERATE THAT VARIABLE'S .M FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.splitsUITree.SelectedNodes)
    beep;
    disp('Need to select a processing split first!');
    handles.Process.convertVarHardDynamicButton.Value=~handles.Process.convertVarHardDynamicButton.Value;
    return;
end

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    beep;
    disp('Need to have an argument selected!');
    handles.Process.convertVarHardDynamicButton.Value=~handles.Process.convertVarHardDynamicButton.Value;
    return;
end

isHC=handles.Process.convertVarHardDynamicButton.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

load(projectSettingsMATPath,'VariableNamesList','NonFcnSettingsStruct');

splitName=handles.Process.splitsUITree.SelectedNodes.Text;
splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;

if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];

% Get the name in the GUI of the currently selected variable.
varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;
varRow=ismember(VariableNamesList.GUINames,varName);
saveName=VariableNamesList.SaveNames{varRow};

fileName=[folderName slash saveName '_' splitCode '.m'];

if isequal(fig.SelectionType,'open') % Double click
    edit(fileName);
    return;
end

VariableNamesList.IsHardCoded{varRow}=isHC;
save(projectSettingsMATPath,'VariableNamesList','-append');

if ~isHC        
    return;
end

% Check if the hard-coded variables folder exists yet. If not, make it.
if exist(folderName,'dir')~=7
    mkdir(folderName);
end

% Check if the currently selected hard-coded variable has a .m file yet. If
% not, make it from template. Include the split code in the .m file name.
if exist(fileName,'file')~=2
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'hardCodedVar_Template.m'];    
    createFileFromTemplate(templatePath,fileName,[saveName '_' splitCode]);
end