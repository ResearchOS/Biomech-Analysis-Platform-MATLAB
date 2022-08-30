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
        if ismember(varName,currVars)
            doDelete=0; % Indicates to not delete the variable.
            disp(['Input Variable ''' varName ''' is used in Split ''' splitNamesIn{j} ''' by Function ''' Digraph.Nodes.FunctionNames{i} '''']);
        end
    end

    if searchOutputs==0
        continue;
    end

    splitNamesOut=fieldnames(Digraph.Nodes.OutputVariableNames{i});

    for j=1:length(splitNamesOut)
        currVars=Digraph.Nodes.OutputVariableNames{i}.(splitNamesOut{j});

    end

end