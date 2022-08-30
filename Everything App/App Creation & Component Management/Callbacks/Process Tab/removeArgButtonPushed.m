function []=removeArgButtonPushed(src,event)

%% PURPOSE: DELETE A SPLIT OF A VARIABLE FROM THE ALL ARGS LIST, AND FROM ALL FUNCTIONS TOO. IF IT'S BEING USED, PROMPT TO ASK IF IT SHOULD STILL BE REMOVED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.varsListbox.SelectedNodes;
if isempty(selNode)
    disp('Must select a variable first!');
    return;
end

text=selNode.Text;
if ~contains(text,' (') % This is not a split within a variable.
    disp('Must select a specific split within a variable, not the variable itself!');
    return;
end

spaceIdx=strfind(selNode.Text,' ');
splitCode=selNode.Text(spaceIdx(end)+2:end-1);

varNode=selNode.Parent;
varName=varNode.Text;

searchOutputs=0;
if length(varNode.Children)==1 % Removing the variable in its entirety.
    response=questdlg(['This will remove the variable ''' varName ''' entirely. Are you sure you want to do this?'],'Confirm','No');
    if ~isequal(response,'Yes')
        return;
    end
    searchOutputs=1;
end    

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'VariableNamesList','Digraph');

doDelete=1; % Indicates to delete the variable (if not found).
% outputRows=[];
% count=0;
for i=1:length(Digraph.Nodes.FunctionNames) % Look through each function to see if the variable is being used anywhere.
    % Inputs should have the name & splitCode matching exactly.
    % If about to delete the variable as a whole, then outputs should also
    % be looked through (in which case the split code may not match).

    if ~isstruct(Digraph.Nodes.InputVariableNames{i})
        continue;
    end

    splitNamesIn=fieldnames(Digraph.Nodes.InputVariableNames{i});

    for j=1:length(splitNamesIn)
        currVars=Digraph.Nodes.InputVariableNames{i}.(splitNamesIn{j});
        if isempty(currVars)
            continue;
        end
        varIdx=ismember(currVars,[varName ' (' splitCode ')']);
        if any(varIdx)
            doDelete=0; % Indicates to not delete the variable.
            disp(['Input Variable ''' currVars{varIdx} ''' is used by Function ''' Digraph.Nodes.FunctionNames{i} ''' in Split ''' splitNamesIn{j}  '''']);
        end
    end

    if searchOutputs==0
        continue;
    end

    splitNamesOut=fieldnames(Digraph.Nodes.OutputVariableNames{i});
%     spaceIdx=strind(varName,' ');
%     varNameOut=varName(1:spaceIdx(end)-1); % Ignoring the split.

    for j=1:length(splitNamesOut)
        currVars=Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j});
        if isempty(currVars)
            continue;
        end
        outSplitCode=currVars{1}(end-3:end-1);
        if ismember([varName ' (' outSplitCode ')'],currVars)
%             count=count+1;
%             doDelete=0;
%             outputRows(count)=i;
            disp(['Output Variable ''' varName ''' is Used in Split ''' splitNamesOut{j} ''' by Function ''' Digraph.Nodes.FunctionNames{i} '''']);
            varNamesOut=Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j});
            varNamesOut=varNamesOut(~ismember(varNamesOut,[varName ' (' outSplitCode ')']));
            Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j})=varNamesOut;
        end

    end

end

if doDelete==0
    disp('No variables removed because they are currently being used!');
    return;
end

%% Delete the variable from the VariableNamesList
delete(selNode);

if isempty(varNode.Children)
    delete(varNode);
    varRow=ismember(VariableNamesList.GUINames,varName);
    VariableNamesList.GUINames(varRow)=[];
    VariableNamesList.SaveNames(varRow)=[];
    VariableNamesList.SplitCodes(varRow)=[];
    VariableNamesList.SplitNames(varRow)=[];
    VariableNamesList.IsHardCoded(varRow)=[];
    VariableNamesList.Descriptions(varRow)=[];
    VariableNamesList.Level(varRow)=[];
    highlightedFcnsChanged(fig,Digraph);
    save(projectSettingsMATPath,'VariableNamesList','Digraph','-append');
else
    save(projectSettingsMATPath,'Digraph','-append');
end

%% Delete the variable from the Digraph.
% outputRows=unique(outputRows);
% for i=outputRows
% 
%     splitNamesOut=fieldnames(Digraph.Nodes.OutputVariableNames{i});
% 
%     for j=1:length(splitNamesOut)
%         varNames=Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j});
%         % Remove the split from the end
%         varNamesNoSplit=cell(length(varNames),1);
%         for k=1:length(varNames)
%             varNamesNoSplit{k}=varNames{k}(1:end-6);
%         end
%         varNames=varNames(~ismember(varNamesNoSplit,varName));
%         Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j})=varNames;
%     end
% 
% end