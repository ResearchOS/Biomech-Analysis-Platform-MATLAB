function []=makeAssignedVarsNodes(fig,Stats,tableName)

%% PURPOSE: POPULATE THE ASSIGNED VARS UI TREE
handles=getappdata(fig,'handles');

delete(handles.Stats.assignedVarsUITree.Children);

repNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Repetition');
dataNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Data');

if isfield(Stats.Tables.(tableName),'RepetitionColumns')
    for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
        uitreenode(repNode,'Text',Stats.Tables.(tableName).RepetitionColumns(i).Name);        
    end
end

if isfield(Stats.Tables.(tableName),'DataColumns')
    for i=1:length(Stats.Tables.(tableName).DataColumns)
        a=uitreenode(dataNode,'Text',Stats.Tables.(tableName).DataColumns(i).Name);
        if isfield(Stats.Tables.(tableName).DataColumns,'Function') && ~isempty(Stats.Tables.(tableName).DataColumns(i).Function)
            uitreenode(a,'Text',Stats.Tables.(tableName).DataColumns(i).Function);
        end
    end
end

expand(repNode);
expand(dataNode);