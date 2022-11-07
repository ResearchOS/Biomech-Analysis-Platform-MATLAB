function []=editPubTableButtonPushed(src,event)

%% PURPOSE: OPEN THE WINDOW TO EDIT THE CURRENT PUBLICATION TABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

tableName=handles.Stats.pubTablesUITree.SelectedNodes.Text;

currPubTable=Stats.PubTables.(tableName);

r=currPubTable.Size.numRows;
c=currPubTable.Size.numCols;

%% Create the figure to edit the current table.
Q=uifigure('Name','Edit Pub Table','DeleteFcn',@(Q,event) pubTableEditWindowDeleteFcn(Q,fig),'AutoResizeChildren','off','SizeChangedFcn',@(Q,event) editPubTableSizeChangedFcn(Q));
Qhandles.numRowsLabel=uilabel(Q,'Text','# Rows','Position',[10 450 100 30]);
Qhandles.numRowsEditField=uieditfield(Q,'numeric','Value',r,'Position',[60 450 100 30],'ValueChangedFcn',@(numRowsEditField,event) numRowsEditFieldValueChanged(numRowsEditField));
Qhandles.numColsLabel=uilabel(Q,'Text','# Cols','Position',[250 450 100 30]);
Qhandles.numColsEditField=uieditfield(Q,'numeric','Value',c,'Position',[300 450 100 30],'ValueChangedFcn',@(numColsEditField,event) numColsEditFieldValueChanged(numColsEditField));
Qhandles.tablePanel=uipanel(Q,'BackgroundColor',[0.9 0.9 0.9],'Position',[10 10 580 430],'Scrollable','on','AutoResizeChildren','off');

setappdata(Q,'handles',Qhandles);
setappdata(Q,'pubTable',currPubTable);
setappdata(Q,'tableName',tableName);

% Create the objects for each individual cell.
% tableNames=fieldnames(Stats.Tables);
createCells(Q,currPubTable,Stats.Tables,fig);