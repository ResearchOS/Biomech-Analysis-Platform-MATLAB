function []=tableDropDownValueChanged(src,allTables)

%% PURPOSE: CHANGE THE DISPLAY OF THE CURRENTLY SELECTED VARIABLES.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% label=handles.
coords=src.Parent.Tag(2:end-1);
coordsSplit=strsplit(coords,',');
i=str2double(coordsSplit{1});
j=str2double(coordsSplit{2});

tableName=handles.tableDropDown(i,j).Value;

if isequal(tableName,'Literal')
    vis=true;
    varItems={''};
else
    vis=false;
    varItems={allTables.(handles.tableDropDown(i,j).Value).DataColumns.Name};
end

handles.varsDropDown(i,j).Visible=~vis;
handles.varsDropDown(i,j).Items=varItems;
handles.repVarDropDown(i,j).Visible=~vis;

handles.valueEditField(i,j).Visible=vis;

if ~isequal(tableName,'Literal')
    varsDropDownValueChanged(src,allTables);
end