function [] = initViewsDropdown(src, Current_Analysis)

%% PURPOSE: WHEN SWITCHING TO A NEW ANALYSIS, INITIALIZE THE VIEWS DROPDOWN.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

sqlquery = ['SELECT VW_ID FROM VW_AN WHERE AN_ID = ''' Current_Analysis ''';'];
t = fetchQuery(sqlquery);
uuids = t.VW_ID;
str = getCondStr(uuids);

sqlquery = ['SELECT UUID, Name FROM Views_Instances WHERE UUID IN ' str];
t = fetchQuery(sqlquery);
viewNames = t.Name;
uuids = t.UUID;

handles.Process.viewsDropDown.Items = viewNames;
handles.Process.viewsDropDown.ItemsData = uuids;

Current_View = getCurrent('Current_View');
idx = ismember(uuids,Current_View);
handles.Process.viewsDropDown.Value = uuids{idx};