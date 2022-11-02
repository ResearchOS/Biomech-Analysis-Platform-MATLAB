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

vars=vars(~ismember(vars,assignedVars)); % Don't allow there to be the same variable in the all vars and assigned vars list boxes

[~,varsSortIdx]=sort(upper(vars));
vars=vars(varsSortIdx);

[~,assignedVarsSortIdx]=sort(upper(assignedVars));
assignedVars=assignedVars(assignedVarsSortIdx);

%% Create the popup window
Q=uifigure('Visible','on','Name','Assign Multi Vars','DeleteFcn',@(Q,event) multiRepPopupWindowDeleteFcn(Q));

% All data variables listbox
Qhandles.allDataVarsListbox=uitree(Q,'Position',[10 10 200 350],'Visible','on');
% All assigned data variables listbox
Qhandles.assignedDataVarsListbox=uitree(Q,'Position',[270 10 200 350],'Visible','on','SelectionChangedFcn',@(Q,event) assignedDataVarsListboxSelectionChanged(Q));
% Assign data variable button
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignMultVarStatsButtonPushed(Q));
% Unassign data variable button
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignMultVarStatsButtonPushed(Q));
% Categories text area (independent of which data vars are assigned)
Qhandles.categoriesTextArea=uitextarea(Q,'Position',[10 375 500 100],'ValueChangedFcn',@(Q,event) categoriesTextAreaValueChanged(Q));

setappdata(Q,'handles',Qhandles);
setappdata(Q,'tableName',tableName);
setappdata(Q,'allDataVars',vars);
setappdata(Q,'assignedVars',assignedVars);
setappdata(Q,'cats',cats);
setappdata(Q,'repVarIdx',varIdx)

makeMultVarStatsNodes(Q,cats,vars,assignedVars);