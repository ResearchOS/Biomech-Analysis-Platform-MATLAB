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
    load(projectSettingsMATPath,'VariableNamesList','Digraph','NonFcnSettingsStruct');
else
    load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');
end

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

    save(projectSettingsMATPath,'VariableNamesList','NonFcnSettingsStruct','-append');
    % This is not part of "makeVarNodes.m" because it deals with
    % initialization, and is therefore a slightly different operation.
    % Maybe in the future.
    for i=1:numVarsNoExist
        varNode=uitreenode(handles.Process.varsListbox,'Text',guiNames{sortIdx(i)});
        splitNames=VariableNamesList.SplitNames{i};
        splitCodes=VariableNamesList.SplitCodes{i};
        for j=1:length(splitCodes)
            a=uitreenode(varNode,'Text',[splitNames{i} '(' splitCodes{j} ')']);
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
    VariableNamesList.SplitNames=[VariableNamesList.SplitNames; repmat({splitName},numVarsNoExist,1)];
    VariableNamesList.SplitCodes=[VariableNamesList.SplitCodes; repmat({splitCode},numVarsNoExist,1)];
    VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({'Enter Arg Description Here'},numVarsNoExist,1)];
    VariableNamesList.IsHardCoded=[VariableNamesList.IsHardCoded; repmat({0},numVarsNoExist,1)];
    VariableNamesList.Level=[VariableNamesList.Level; repmat({'T'},numVarsNoExist,1)];
end

%% Update the existing variables in the structure (if any)
% if any(~noExistVarIdx)
%     existVarsMatNums=find(existVarsMatIdx==1);
%     noExistVarsNums=find(noExistVarIdx==0);
%     for i=1:length(existVarsMatNums)
%         assert(isequal(VariableNamesList.GUINames{existVarsMatNums(i)},guiNames{noExistVarsNums(i)}));
%         assert(isequal(VariableNamesList.SaveNames{existVarsMatNums(i)},guiVarNames{noExistVarsNums(i)}));
%         
%         VariableNamesList.SplitNames{existVarsMatNums(i)}=[VariableNamesList.SplitNames{existVarsMatNums(i)}; {splitName}];
%         VariableNamesList.SplitCodes{existVarsMatNums(i)}=[VariableNamesList.SplitCodes{existVarsMatNums(i)}; {splitCode}];
%         VariableNamesList.Descriptions{existVarsMatNums(i)}='Enter Arg Description Here';
%         VariableNamesList.IsHardCoded{existVarsMatNums(i)}=0;
%         VariableNamesList.Level{existVarsMatNums(i)}='T';
%     end
% end

save(projectSettingsMATPath,'VariableNamesList','NonFcnSettingsStruct','-append');

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));
makeVarNodes(fig,sortIdx,VariableNamesList);
% handles.Process.varsListbox.Items=VariableNamesList.GUINames;
% handles.Process.varsListbox.Value=VariableNamesList.GUINames{1};
% handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{1};


%% Split name does not yet exist
% Check if any/all of the variables being saved are part of the
% split already

% Get the idx of the variables not already in the split
% currVarsNotInSplit=~(ismember(splitName,getUniqueMembers(VariableNamesList.SplitNames)) & ismember(guiNames,VariableNamesList.GUINames));
%
% VariableNamesList.GUINames=[VariableNamesList.GUINames; guiNames(currVarsNotInSplit)];
% VariableNamesList.SaveNames=[VariableNamesList.SaveNames; guiVarNames(currVarsNotInSplit)]; % Does not include the split code
% VariableNamesList.SplitNames=[VariableNamesList.SplitNames; repmat(splitName,sum(currVarsNotInSplit),1)];
% VariableNamesList.SplitCodes=[VariableNamesList.SplitCodes; repmat(splitCode,sum(currVarsNotInSplit),1)];
% VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({'Enter Arg Description Here'},sum(currVarsNotInSplit),1)];
% VariableNamesList.IsHardCoded=[VariableNamesList.IsHardCoded; repmat({0},sum(currVarsNotInSplit),1)];
% VariableNamesList.Level=[VariableNamesList.Level; repmat({''},sum(currVarsNotInSplit),1)];

% handles.Process.varsListbox.Items=VariableNamesList.GUINames;
% handles.Process.varsListbox.Value=VariableNamesList.GUINames{1};
% handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{1};

% Index {1} because logsheet is always the first node.
% if isequal(Digraph.Nodes.SplitNames{1},{''})
%     Digraph.Nodes.SplitNames{1}={splitName};
% elseif ~ismember(splitName,Digraph.Nodes.SplitNames{1})
%     Digraph.Nodes.SplitNames{1}=[Digraph.Nodes.SplitNames{1}; {splitName}];
% end

save(projectSettingsMATPath,'VariableNamesList','Digraph','NonFcnSettingsStruct','-append');

varsListBoxValueChanged(fig);