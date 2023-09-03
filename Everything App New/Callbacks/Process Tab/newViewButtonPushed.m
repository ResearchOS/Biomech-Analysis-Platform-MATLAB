function [] = newViewButtonPushed(src,event)

%% PURPOSE: CREATE A NEW VIEW. ASSUMES THAT THE DIGRAPH IS ALREADY UP TO DATE.
% From currently selected nodes? Ask if want downstream & upstream deps.
% Copy current view entirely if nothing is selected?

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

name = promptName('Enter View Name','Default');
if isequal(name,'ALL')
    disp('Reserved name ''ALL'' choose another!');
    return;
end

viewStruct = createNewObject(true, 'VW', name, '', '', true);
uuid = viewStruct.UUID;

Current_Analysis = getCurrent('Current_Analysis');
linkObjs(uuid, Current_Analysis);

G = getappdata(fig,'digraph');
markerSize = getappdata(fig,'markerSize');

selIdx = ismember(markerSize,8);
selUUIDs = G.Nodes.Name(selIdx);

a = questdlg('Which direction? Exit this window to abort','Select Direction','Upstream','Downstream','Both','Downstream');
if isempty(a)
    return;
end
switch a
    case 'Upstream'
        dir = {'up'};
    case 'Downstream'
        dir = {'down'};
    case 'Both'
        dir = {'up','down'};
end

% Allow for multiple selections to seed the new view. Get all dependencies
% in the specified direction.
deps = {};
for i=1:length(selUUIDs)
    if ismember('up',dir)
        [~,tmp] = getDeps(G,'up',selUUIDs{i});
        deps = [deps; tmp; selUUIDs(i)];
    end
    if ismember('down',dir)
        [~,tmp] = getDeps(G,'down',selUUIDs{i});
        deps = [deps; tmp; selUUIDs(i)];
    end
end

% If nothing is selected, copy the view
if isempty(selUUIDs)
    Current_View = getCurrent('Current_View');
    sqlquery = ['SELECT InclNodes FROM Views_Instances WHERE UUID = ''' Current_View ''';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    deps = t.InclNodes;
end

deps = unique(deps,'stable');

depsJSON = jsonencode(deps);
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' depsJSON ''' WHERE UUID = ''' uuid ''';'];
execute(conn, sqlquery);

handles.Process.viewsDropDown.Items = [handles.Process.viewsDropDown.Items, {name}];
handles.Process.viewsDropDown.ItemsData = [handles.Process.viewsDropDown.ItemsData, {uuid}];
handles.Process.viewsDropDown.Value = uuid;

viewsDropDownValueChanged(fig);
