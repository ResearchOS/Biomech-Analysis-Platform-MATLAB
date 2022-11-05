function []=multiRepPopupWindowDeleteFcn(src,event)

%% PURPOSE: STORE THE CHANGES MADE IN THE POPUP WINDOW BACK TO THE STATS VARIABLE IN THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tableName=getappdata(fig,'tableName');
allDataVars=getappdata(fig,'allDataVars');
assignedVars=getappdata(fig,'assignedVars');
cats=getappdata(fig,'cats');
repVarIdx=getappdata(fig,'repVarIdx');

pguiFig=findall(0,'Name','pgui');
% pguiHandles=getappdata(pguiFig,'handles');

Stats=getappdata(pguiFig,'Stats');

Stats.Tables.(tableName).RepetitionColumns(repVarIdx).Mult.Categories=cats;
Stats.Tables.(tableName).RepetitionColumns(repVarIdx).Mult.DataVars=assignedVars;

setappdata(pguiFig,'Stats',Stats);