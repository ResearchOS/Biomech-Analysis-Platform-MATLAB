function []=showVarButtonPushed(src)

%% PURPOSE: SHOW THE CURRENTLY SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

varName=handles.Projects.showVarDropDown.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

if isequal('NonFcnSettingsStruct',varName)
    load(projectSettingsMATPath,'NonFcnSettingsStruct');
    assignin('base',varName,NonFcnSettingsStruct);
    evalin('base',['openvar(''' varName ''');']);
    return;
end

Q=uifigure('Name','Edit Settings Variable');

% Organize the var data in table form
if isequal('VariableNamesList',varName)
    load(projectSettingsMATPath,'VariableNamesList');
    headers=fieldnames(VariableNamesList);
    for i=1:length(headers)
        array(:,i)=VariableNamesList.(headers{i});
    end  
    tableVar=array2table(array,'VariableNames',headers);
    Qhandles.table=uitable(Q,'Data',tableVar,'Position',[10 10 500 400]);
end 

if isequal('Digraph',varName)
    load(projectSettingsMATPath,'Digraph');
    edgeHeaders=fieldnames(Digraph.Edges);
    nodeHeaders=fieldnames(Digraph.Nodes);
    for i=1:length(edgeHeaders)
        edgeArray{:,i}=Digraph.Edges.(edgeHeaders{i});
    end
    for i=1:length(nodeHeaders)
        nodeArray{:,i}=Digraph.Nodes.(nodeHeaders{i});
    end
    edgeTableVar=array2table(edgeArray,'VariableNames',edgeHeaders);
    nodeTableVar=array2table(nodeArray,'VariableNames',nodeHeaders);
    Qhandles.edgeTable=uitable(Q,'Data',edgeTableVar,'Position',[10 10 100 100]);
    Qhandles.nodeTable=uitable(Q,'Data',nodeTableVar,'Position',[10 10 100 100]);
end

Qhandles.saveVarButton=uibutton(Q,'Text','Save','Position',[10 10 100 100],'ButtonPushedFcn',@(saveVarButton,event) saveVarButtonPushed(saveVarButton));