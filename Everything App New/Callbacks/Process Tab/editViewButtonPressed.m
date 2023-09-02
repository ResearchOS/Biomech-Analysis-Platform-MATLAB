function [] = editViewButtonPressed(src,event)

%% PURPOSE: OPEN THE CURRENT VIEW AS JSON TO EDIT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value = handles.Process.editViewButton.Value;

uuid = getCurrent('Current_View');

if value==1
    editObj(fig,uuid);
elseif value==0
    saveEdits(fig,uuid);
end