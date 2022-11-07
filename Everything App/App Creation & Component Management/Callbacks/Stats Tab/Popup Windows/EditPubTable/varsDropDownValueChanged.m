function []=varsDropDownValueChanged(src,allTables,repVar)

%% PURPOSE: CHANGE THE LIST OF MULTI-REPETITION VARIABLES THAT ARE AVAILABLE TO THE CURRENT DATA VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

coords=src.Parent.Tag;
coords=strsplit(coords(2:end-1),',');
r=str2double(coords{1});
c=str2double(coords{2});

tableName=handles.tableDropDown(r,c).Value;
varName=handles.varsDropDown(r,c).Value;
if ~exist('repVar','var')
    repVar=handles.repVarDropDown(r,c).Value;
end

repCols=allTables.(tableName).RepetitionColumns;

repVarItems={''}; % Will be the value if there are no multi-repetition variables in this table.
for i=1:length(repCols)

    if isempty(repCols(i).Mult)
        continue; % This is not a multi-rep var
    end

    if ~ismember(varName,repCols(i).Mult.DataVars)
        continue; % This variable is not a multiple rep variable.
    end

    repVarItems=[{''}; repCols(i).Mult.Categories]; % The list of repetition variable values

end

if ~ismember(repVar,repVarItems)
    repVar='';
end

handles.repVarDropDown(r,c).Items=repVarItems;
handles.repVarDropDown(r,c).Value=repVar;