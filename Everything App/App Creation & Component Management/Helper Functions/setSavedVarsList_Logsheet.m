function []=setSavedVarsList_Logsheet(splitName,guiNames)

%% PURPOSE: UPDATE AND SAVE THE LIST OF SAVED VARIABLES TO THE CURRENT PROJECT'S SETTINGS MAT PATH
% NOTE: IN THIS LOGSHEET VERSION OF SETSAVEDVARSLIST, IT ACCEPTS THE NAMES
% OF THE VARS AS SPECIFIED IN THE GUI
% Inputs:
% splitName: The name of the current split to save the variables to (char)
% guiNames: The names of the variables as specified in the GUI (cell array
% of chars)

fig=evalin('base','gui;');
handles=getappdata(fig,'handles');
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

assert(ismember('Digraph',projectSettingsVarNames));

if ismember('VariableNamesList',projectSettingsVarNames)
%     load(projectSettingsMATPath,'VariableNamesList','Digraph','NonFcnSettingsStruct');
    VariableNamesList=getappdata(fig,'VariableNamesList');
else
%     load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');
end
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

if size(guiNames,1)<size(guiNames,2)
    guiNames=guiNames';
end

guiVarNames=genvarname(guiNames);

if ~iscell(splitName)
    splitName={splitName};
end

% Is there ever a reason why the logsheet would not be part of the default split?
splitCode={'001'}; % Initialize as a cell

numVarsNoExist=length(guiNames);

if exist('VariableNamesList','var')~=1 % Initialize the VariableNamesList
    [~,sortIdx]=sort(upper(guiNames));
    VariableNamesList.GUINames=guiNames(sortIdx);
    VariableNamesList.SaveNames=guiVarNames(sortIdx);
    VariableNamesList.SplitNames=repmat({splitName},numVarsNoExist,1); 
    VariableNamesList.SplitCodes=repmat({splitCode},numVarsNoExist,1);
    VariableNamesList.Descriptions=repmat({'Enter Arg Description Here'},numVarsNoExist,1);
    VariableNamesList.Level=repmat({'T'},numVarsNoExist,1);
    VariableNamesList.IsHardCoded=repmat({0},numVarsNoExist,1);

%     save(projectSettingsMATPath,'VariableNamesList','NonFcnSettingsStruct','-append');
    setappdata(fig,'VariableNamesList',VariableNamesList);
    setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
    % This is not part of "makeVarNodes.m" because it deals with
    % initialization, and is therefore a slightly different operation.
    % Maybe in the future.
    for i=1:numVarsNoExist
        varNode=uitreenode(handles.Process.varsListbox,'Text',guiNames{sortIdx(i)});
        splitNames=VariableNamesList.SplitNames{i};
        splitCodes=VariableNamesList.SplitCodes{i};
        for j=1:length(splitCodes)
            a=uitreenode(varNode,'Text',[splitNames{j} '(' splitCodes{j} ')']);
            if i==1 && j==1
                handles.Process.varsListbox.SelectedNodes=a;
            end
        end        
    end
%     handles.Process.varsListbox.Items=VariableNamesList.GUINames;
%     handles.Process.varsListbox.Value=VariableNamesList.GUINames{1};
    handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{1};
    return;
end

noExistVarIdx=~ismember(guiNames,VariableNamesList.GUINames); % The idx of current vars that do not already exist.
numVarsNoExist=sum(noExistVarIdx);

existVarsMatIdx=ismember(VariableNamesList.GUINames,guiNames); % The idx of previous vars that are in the current set.
numVarsExist=sum(existVarsMatIdx);

%% Append new variables to the structure (if any)
if any(~existVarsMatIdx)
    VariableNamesList.GUINames=[VariableNamesList.GUINames; guiNames(noExistVarIdx)];
    VariableNamesList.SaveNames=[VariableNamesList.SaveNames; guiVarNames(noExistVarIdx)]; % Does not include the split code
    if size(VariableNamesList.SplitNames,1)<size(VariableNamesList.SplitNames,2) % Row vector, but should be a column vector
        VariableNamesList.SplitNames=VariableNamesList.SplitNames';
    end
    if size(VariableNamesList.SplitCodes,1)<size(VariableNamesList.SplitCodes,2)
        VariableNamesList.SplitCodes=VariableNamesList.SplitCodes';
    end
    VariableNamesList.SplitNames=[VariableNamesList.SplitNames; repmat({splitName},numVarsNoExist,1)];
    VariableNamesList.SplitCodes=[VariableNamesList.SplitCodes; repmat({splitCode},numVarsNoExist,1)];
    VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({'Enter Arg Description Here'},numVarsNoExist,1)];
    VariableNamesList.IsHardCoded=[VariableNamesList.IsHardCoded; repmat({0},numVarsNoExist,1)];
    VariableNamesList.Level=[VariableNamesList.Level; repmat({'T'},numVarsNoExist,1)];
end

% save(projectSettingsMATPath,'VariableNamesList','NonFcnSettingsStruct','-append');
setappdata(fig,'VariableNamesList',VariableNamesList);
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));
makeVarNodes(fig,sortIdx,VariableNamesList);

% save(projectSettingsMATPath,'VariableNamesList','Digraph','NonFcnSettingsStruct','-append');
setappdata(fig,'VariableNamesList',VariableNamesList);
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
setappdata(fig,'Digraph',Digraph);

varsListBoxValueChanged(fig);