function []=pubTableEditWindowDeleteFcn(Q,fig)

%% PURPOSE: APPLY THE CHANGED SETTINGS TO THE STATS STRUCT IN THE MAIN PGUI WINDOW.
% fig=ancestor(src,'figure','toplevel');

% pgui=findall(0,'Name','pgui');
Stats=getappdata(fig,'Stats');

tableName=getappdata(Q,'tableName');

currTable=getappdata(Q,'pubTable');

Stats.PubTables.(tableName)=currTable;

setappdata(fig,'Stats',Stats);