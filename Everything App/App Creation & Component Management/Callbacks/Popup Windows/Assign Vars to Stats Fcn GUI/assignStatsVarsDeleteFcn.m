function []=assignStatsVarsDeleteFcn(src)

%% PURPOSE: WHEN THE WINDOW CLOSES, ASSIGN THE VARIABLES BACK TO THE PLOTTING VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

pgui=findall(0,'Name','pgui');

Stats=getappdata(pgui,'Stats');

tableName=getappdata(fig,'tableName');
varNodeIdxNum=getappdata(fig,'varNodeIdxNum');
currNode=getappdata(fig,'currNode');

fldNames=fieldnames(currNode);
for i=1:length(fldNames)
    Stats.Tables.(tableName).DataColumns(varNodeIdxNum).(fldNames{i})=currNode.(fldNames{i});
end

setappdata(pgui,'Stats',Stats);