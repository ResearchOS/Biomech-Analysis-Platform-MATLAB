function [] = newViewButtonPushed(src,event)

%% PURPOSE: CREATE A NEW VIEW. ASSUMES THAT THE DIGRAPH IS ALREADY UP TO DATE.
% From currently selected nodes? Ask if want downstream & upstream deps.
% Copy current view entirely if nothing is selected?

global conn globalG viewG;

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

G = viewG;
markerSize = getappdata(fig,'markerSize');

selIdx = ismember(markerSize,8);
selUUIDs = G.Nodes.Name(selIdx);

listOpts = {'Upstream','Downstream','Both','Neighbors Only','Empty'};
a = listdlg('ListString',listOpts,'SelectionMode','single','PromptString','Select the nodes to include in this view.');
a = listOpts{a};
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
if ~ismember(a,{'Neighbors Only','Empty'})
    deps = getObjs(selUUIDs, 'PR', dir);
elseif ~ismember(a,{'Empty'})
    succs = successors(G, selUUIDs);
    preds = predecessors(G, selUUIDs);
    deps = [selUUIDs; preds; succs];
end

% If nothing is selected, copy the view
if isempty(selUUIDs) && ~isequal(a,'Empty')
    Current_View = getCurrent('Current_View');
    sqlquery = ['SELECT InclNodes FROM Views_Instances WHERE UUID = ''' Current_View ''';'];
    t = fetchQuery(sqlquery);
    deps = t.InclNodes;
else
    deps = {};
end

deps = unique(deps,'stable');

depsJSON = jsonencode(deps);
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' depsJSON ''' WHERE UUID = ''' uuid ''';'];
execute(conn, sqlquery);

handles.Process.viewsDropDown.Items = [handles.Process.viewsDropDown.Items, {name}];
handles.Process.viewsDropDown.ItemsData = [handles.Process.viewsDropDown.ItemsData, {uuid}];
handles.Process.viewsDropDown.Value = uuid;

viewsDropDownValueChanged(fig);
