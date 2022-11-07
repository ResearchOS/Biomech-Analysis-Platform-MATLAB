function []=pubTableEditWindowDeleteFcn(Q,fig)

%% PURPOSE: APPLY THE CHANGED SETTINGS TO THE STATS STRUCT IN THE MAIN PGUI WINDOW.
% fig=ancestor(Q,'figure','toplevel');
handles=getappdata(Q,'handles');

% pgui=findall(0,'Name','pgui');
Stats=getappdata(fig,'Stats');

tableName=getappdata(Q,'tableName');

currTable=getappdata(Q,'pubTable');

for r=1:currTable.Size.numRows
    for c=1:currTable.Size.numCols
%         currTable.Cells(r,c).isLiteral=;
        currTable.Cells(r,c).summMeasure=handles.summMeasureDropDown(r,c).Value;
        currTable.Cells(r,c).value=handles.valueEditField(r,c).Value;
        currTable.Cells(r,c).tableName=handles.tableDropDown(r,c).Value;
        currTable.Cells(r,c).varName=handles.varsDropDown(r,c).Value;
        currTable.Cells(r,c).repVar=handles.repVarDropDown(r,c).Value;
    end
end

Stats.PubTables.(tableName)=currTable;

setappdata(fig,'Stats',Stats);