function []=openMultiRepPopupWindow(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO ASSIGN VARIABLES & CATEGORIES TO A REPETITION VARIABLE THAT OCCURS MULTIPLE TIMES PER TRIAL
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

tableNode=handles.Stats.tablesUITree.SelectedNodes;

if isempty(tableNode)
    return;
end

tableName=tableNode.Text;

Stats=getappdata(fig,'Stats');

varName=selNode.Text;

repNodeChildren=handles.Stats.assignedVarsUITree.Children(1).Children; % The 'Repetition' node

varIdx=ismember(repNodeChildren,selNode);

multStruct=Stats.Tables.(tableName).RepetitionColumns;

assert(isfield(multStruct,'Mult'));

multStruct=multStruct(varIdx).Mult;

assert(multStruct.PerTrial==1);

cats=multStruct.Categories;

assignedVars=multStruct.DataVars;

vars={Stats.Tables.(tableName).DataColumns.Name};

%% Create the popup window
Q=figure('Visible','on','Name','Assign Multi Vars','DeleteFcn',@(Q,event) multiRepPopupWindowDeleteFcn(Q));

% All data variables listbox
Qhandles.allDataVarsListbox=uitree(Q,'Position',[10 10 200 450],'Visible','on');
% All assigned data variables listbox
Qhandles.assignedDataVarsListbox=uitree(Q,'Position',[270 10 200 300],'Visible','on','SelectionChangedFcn',@(Q,event) assignedDataVarsListboxSelectionChanged(Q));
% Assign data variable button
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignMultVarStatsButtonPushed(Q));
% Unassign data variable button
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignMultVarStatsButtonPushed(Q));
% Categories text area (independent of which data vars are assigned)
Qhandles.categoriesTextArea=uitextarea(Q,'Position',[10 250 450 200],'ValueChangedFcn',@(Q,event) categoriesTextAreaValueChanged(Q));

setappdata(Q,'handles',Qhandles);
setappdata(Q,'tableName',tableName);

makeMultVarStatsNodes(Q,cats,vars,assignedVars);


% Qhandles.varsListbox=uitree(Q,'Position',[10 10 200 450],'Visible','on');
% Qhandles.selVarsListbox=uitree(Q,'Position',[270 10 200 300],'SelectionChangedFcn',@(Q,event) selVarsStatsListboxValueChanged(Q),'Visible','on');
% Qhandles.varNameInCodeEditField=uieditfield(Q,'Position',[270 310 200 50],'ValueChangedFcn',@(Q,event) varNameInCodeStatsEditFieldValueChanged(Q),'Visible','on');
% % Qhandles.isHardCoded=uicheckbox(Q,'Position',[10 460 150 50],'Value',structComp.IsHardCoded,'Text','Is Hard Coded?','ValueChangedFcn',@(Q,event) isHardCodedCheckboxValueChanged(Q));
% % Qhandles.hardCodedTextArea=uitextarea(Q,'Position',[10 250 450 200],'Visible',Qhandles.isHardCoded.Value,'ValueChangedFcn',@(Q,event) hardCodedValueChanged(Q),'Visible',structComp.IsHardCoded);
% Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignVarStatsButtonPushed(Q),'Visible','on');
% Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignVarStatsButtonPushed(Q),'Visible','on');
% Qhandles.subvarsTextArea=uitextarea(Q,'Position',[270 370 200 50],'ValueChangedFcn',@(Q,event) subvarsStatsTextAreaValueChanged(Q),'Visible','on');

% setappdata(Q,'varNodeIdxNum',varNodeIdxNum);
% setappdata(Q,'guiNames',Stats.Tables.(tableName).DataColumns(varNodeIdxNum).GUINames);
% setappdata(Q,'namesInCode',Stats.Tables.(tableName).DataColumns(varNodeIdxNum).NamesInCode);
% setappdata(Q,'currNode',Stats.Tables.(tableName).DataColumns(varNodeIdxNum));