function []=removeArgButtonPushed(src,varNameInGUI,splitName_Code)

%% PURPOSE: DELETE A SPLIT OF A VARIABLE FROM THE ALL ARGS LIST, AND FROM ALL FUNCTIONS TOO. IF IT'S BEING USED, PROMPT TO ASK IF IT SHOULD STILL BE REMOVED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('varNameInGUI','var')~=1
    runLog=true;
    selNode=handles.Process.varsListbox.SelectedNodes;
else
    runLog=false;
    handles.Process.varsListbox.SelectedNodes=findobj(handles.Process.varsListbox,'Text',varNameInGUI);
    handles.Process.varsListbox.SelectedNodes=findobj(handles.Process.varsListbox.SelectedNodes,'Text',splitName_Code);
    selNode=handles.Process.varsListbox.SelectedNodes;
end
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
splitName=selNode.Text(1:spaceIdx(end)-1);

varNode=selNode.Parent;
varName=varNode.Text;

searchOutputs=0;
if length(varNode.Children)==1 % Removing the variable in its entirety.
    if runLog
        response=questdlg(['This will remove the variable ''' varName ''' entirely. Are you sure you want to do this?'],'Confirm','No');
    else
        response='Yes'; % Auto-select to delete the variable.
    end
    if ~isequal(response,'Yes')
        return;
    end
    searchOutputs=1;
end    

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'VariableNamesList','Digraph');
Digraph=getappdata(fig,'Digraph');
VariableNamesList=getappdata(fig,'VariableNamesList');

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
        spaceIdx=strfind(splitNamesIn{j},'_');
        splitCodeNode=splitNamesIn{j}(spaceIdx+1:end);
        if isempty(currVars)
            continue;
        end
        varIdx=ismember(currVars,[varName ' (' splitCode ')']);
        if any(varIdx)
            % Check whether the input variable is being used in a currently
            % visible split of an existing node (iterate over all splits of
            % all *visible* nodes). Do this by checking for an inedge to
            % the node of that split.
           inEdgeRows=inedges(Digraph,find(ismember(Digraph.Nodes.NodeNumber,Digraph.Nodes.NodeNumber(i))==1));
           splitCodes=Digraph.Edges.SplitCode(inEdgeRows); % The splits of the inedges
           if ismember(splitCodeNode,splitCodes) % If there is an edge of this split going into this node, don't delete the variable.
               doDelete=0; % Indicates to not delete the variable.
               disp(['Input Variable ''' currVars{varIdx} ''' is used by Function ''' Digraph.Nodes.FunctionNames{i} ''' in Split ''' splitNamesIn{j}  '''']);
           else  % Delete that input variable from that split. If no more input variables are left in that split, delete the split entirely.
                Digraph.Nodes.InputVariableNames{i}.(splitNamesIn{j})=Digraph.Nodes.InputVariableNames{i}.(splitNamesIn{j})(~ismember(Digraph.Nodes.InputVariableNames{i}.(splitNamesIn{j}),[varName ' (' splitCode ')']));
                if isempty(Digraph.Nodes.InputVariableNames{i}.(splitNamesIn{j}))
                    Digraph.Nodes.InputVariableNames{i}=rmfield(Digraph.Nodes.InputVariableNames{i},splitNamesIn{j});
                end
           end
        end
    end

    if searchOutputs==0
        continue;
    end

    if ~isempty(Digraph.Nodes.OutputVariableNames{i})
        splitNamesOut=fieldnames(Digraph.Nodes.OutputVariableNames{i});
    else
        splitNamesOut='';
    end
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

varRow=ismember(VariableNamesList.GUINames,varName);

VariableNamesList.SplitCodes{varRow}=VariableNamesList.SplitCodes{varRow}(~ismember(VariableNamesList.SplitCodes{varRow},splitCode));
VariableNamesList.SplitNames{varRow}=VariableNamesList.SplitNames{varRow}(~ismember(VariableNamesList.SplitNames{varRow},splitName));

if isempty(varNode.Children)
    delete(varNode);    
    VariableNamesList.GUINames(varRow)=[];
    VariableNamesList.SaveNames(varRow)=[];
    VariableNamesList.SplitCodes(varRow)=[];
    VariableNamesList.SplitNames(varRow)=[];
    VariableNamesList.IsHardCoded(varRow)=[];
    VariableNamesList.Descriptions(varRow)=[];
    VariableNamesList.Level(varRow)=[];
    highlightedFcnsChanged(fig,Digraph);    
end

% save(projectSettingsMATPath,'VariableNamesList','Digraph','-append');
setappdata(fig,'VariableNamesList',VariableNamesList);
setappdata(fig,'Digraph',Digraph);

handles.Process.fcnsArgsSearchField.Value='';

[~,alphabetIdx]=sort(upper(VariableNamesList.GUINames));
makeVarNodes(fig,alphabetIdx,VariableNamesList);

if runLog
    varNameInGUI=varName;
    splitName_Code=text;
    desc='Delete a variable';
    updateLog(fig,desc,varNameInGUI,splitName_Code);
end