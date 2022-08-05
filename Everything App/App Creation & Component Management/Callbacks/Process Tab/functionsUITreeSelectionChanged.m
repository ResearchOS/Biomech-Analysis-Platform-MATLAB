function []=functionsUITreeSelectionChanged(src,event)

%% PURPOSE: DO SOMETHING WHEN A SPECIFIC NODE IN THE FUNCTIONS UI TREE OBJECT IS SELECTED. I.E. SHOW PROPER DESCRIPTION, ETC.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
try
    assert(all(ismember({'Digraph'},varNames)));
catch
    return;
end

if ismember(varNames,'VariableNamesList')
    load(projectSettingsMATPath,'Digraph','VariableNamesList');
else
    load(projectSettingsMATPath,'Digraph');
end

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    handles.Process.fcnDescriptionTextArea.Value='Enter Arg Description Here';
    return;
end

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
a=handles.Process.fcnArgsUITree.SelectedNodes;
for i=1:2
    if ~isempty(nodeNum)
        break;
    end
    a=a.Parent;
    nodeNum=a.NodeData;
end

assert(~isempty(nodeNum));

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

handles.Process.fcnDescriptionTextArea.Value=Digraph.Nodes.Descriptions{nodeRow};

b=handles.Process.fcnArgsUITree.SelectedNodes.Parent;
if isprop(b,'Text') && ismember(b.Text,{'Inputs','Outputs'}) % Ensure that this is a variable
    varRow=ismember(VariableNamesList.GUINames,handles.Process.fcnArgsUITree.SelectedNodes.Text);
    handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{varRow};
    handles.Process.argNameInCodeFIeld.Value=VariableNamesList.SaveNames{varRow};
end

specifyTrialsName=Digraph.Nodes.SpecifyTrials{nodeRow};

handles.Process.specifyTrialsLabel.Text=specifyTrialsName;

handles.Process.markImportFcnCheckbox.Value=Digraph.Nodes.IsImport(nodeRow);