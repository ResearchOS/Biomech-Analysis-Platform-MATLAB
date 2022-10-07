function []=assignStatsVarsButtonPushed(src,event)

%% PURPOSE: ASSIGN A VARIABLE TO THE CURRENT STATS TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

if isempty(handles.Stats.assignedVarsUITree.SelectedNodes)
    return;
end

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isequal(class(selNode.Parent),'matlab.ui.container.Tree') || isequal(class(selNode.Parent.Parent),'matlab.ui.container.Tree')
    disp('Must select the function!'); % This excludes the repetition nodes, because they don't have nodes at this level
    return;
end

fcnName=selNode.Text;

varNode=selNode.Parent;
varName=selNode.Parent.Text;

varNodeIdxNum=find(ismember(selNode.Parent.Parent.Children,varNode)==1);

if ~isfield(Stats.Tables.(tableName).DataColumns,'GUINames') || isempty(Stats.Tables.(tableName).DataColumns(varNodeIdxNum).GUINames)
    Stats.Tables.(tableName).DataColumns(varNodeIdxNum).GUINames={varName};
    Stats.Tables.(tableName).DataColumns(varNodeIdxNum).NamesInCode={'data'};
    Stats.Tables.(tableName).DataColumns(varNodeIdxNum).SubVars={''};
    setappdata(fig,'Stats',Stats);
end

%% Make the popup GUI window
VariableNamesList=getappdata(fig,'VariableNamesList');
[~,idx]=sort(upper(VariableNamesList.GUINames));
Q=uifigure('Visible','on','Name','Assign Variables','DeleteFcn',@(Q,event) assignStatsVarsDeleteFcn(Q));
Qhandles.varsListbox=uitree(Q,'Position',[10 10 200 450],'Visible','on');
Qhandles.selVarsListbox=uitree(Q,'Position',[270 10 200 300],'SelectionChangedFcn',@(Q,event) selVarsStatsListboxValueChanged(Q),'Visible','on');
Qhandles.varNameInCodeEditField=uieditfield(Q,'Position',[270 310 200 50],'ValueChangedFcn',@(Q,event) varNameInCodeStatsEditFieldValueChanged(Q),'Visible','on');
% Qhandles.isHardCoded=uicheckbox(Q,'Position',[10 460 150 50],'Value',structComp.IsHardCoded,'Text','Is Hard Coded?','ValueChangedFcn',@(Q,event) isHardCodedCheckboxValueChanged(Q));
% Qhandles.hardCodedTextArea=uitextarea(Q,'Position',[10 250 450 200],'Visible',Qhandles.isHardCoded.Value,'ValueChangedFcn',@(Q,event) hardCodedValueChanged(Q),'Visible',structComp.IsHardCoded);
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignVarStatsButtonPushed(Q),'Visible','on');
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignVarStatsButtonPushed(Q),'Visible','on');
Qhandles.subvarsTextArea=uitextarea(Q,'Position',[270 370 200 50],'ValueChangedFcn',@(Q,event) subvarsStatsTextAreaValueChanged(Q),'Visible','on');

setappdata(Q,'handles',Qhandles);
setappdata(Q,'tableName',tableName);
setappdata(Q,'varNodeIdxNum',varNodeIdxNum);
setappdata(Q,'guiNames',Stats.Tables.(tableName).DataColumns(varNodeIdxNum).GUINames);
setappdata(Q,'namesInCode',Stats.Tables.(tableName).DataColumns(varNodeIdxNum).NamesInCode);
setappdata(Q,'currNode',Stats.Tables.(tableName).DataColumns(varNodeIdxNum));
makeVarNodesStatsArgsPopup(Q,idx,VariableNamesList,Stats.Tables.(tableName).DataColumns(varNodeIdxNum));