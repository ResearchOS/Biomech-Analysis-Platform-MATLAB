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

if isempty(handles.Process.fcnArgsUITree.SelectedNodes) || ...
        isequal(class(handles.Process.fcnArgsUITree.SelectedNodes.Parent),'matlab.ui.container.CheckBoxTree') || ...
        ~ismember(handles.Process.fcnArgsUITree.SelectedNodes.Parent.Text,{'Inputs','Outputs'})
    beep;
    disp('Need to have an argument selected in the function args pane!');
    handles.Process.convertVarHardDynamicButton.Value=~handles.Process.convertVarHardDynamicButton.Value;
    return;
end

isHC=handles.Process.convertVarHardDynamicButton.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

% load(projectSettingsMATPath,'VariableNamesList');
VariableNamesList=getappdata(fig,'VariableNamesList');

% splitText=handles.Process.splitsUITree.SelectedNodes.Text;
splitsList=getSplitsOrder(handles.Process.splitsUITree.SelectedNodes,handles.Process.splitsUITree.Tag);
splitsListIn=splitsList(1:end-1);
splitName=splitsList{end};
% spaceIdx=strfind(splitText,' ');
% splitName=splitText(1:spaceIdx-1);
splitCode=genSplitCode(projectSettingsMATPath,splitsListIn,splitName);
% splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;

if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];

% Get the name in the GUI of the currently selected variable.
varText=handles.Process.fcnArgsUITree.SelectedNodes.Text;
spaceIdx=strfind(varText,' ');
varName=varText(1:spaceIdx-1);

varRow=ismember(VariableNamesList.GUINames,varName);
saveName=VariableNamesList.SaveNames{varRow};

fileName=[folderName slash saveName '_' splitCode '.m'];

if isequal(fig.SelectionType,'open') % Double click
    edit(fileName);
    return;
end

VariableNamesList.IsHardCoded{varRow}=isHC;
% save(projectSettingsMATPath,'VariableNamesList','-append');
setappdata(fig,'VariableNamesList',VariableNamesList);

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