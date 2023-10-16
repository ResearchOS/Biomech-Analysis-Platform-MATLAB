function [] = contextMenuCallbacks(src, event, args)

%% PURPOSE: ALL THE CALLBACKS FOR THE CONTEXT MENUS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

src = get(fig,'CurrentObject');

% handles = handles.Process.ContextMenu;

if exist('event','var')~=1
    event = '';
end
if exist('args','var')~=1
    args = '';
end

uuid = src.NodeData.UUID;

name = args.Name;

switch name
    case 'CopyToNew'
        args.UUID = uuid;
        copyToNewPS(src, args);
    case 'OpenMFile'
        openMFile(fig);
    case 'Edit'
        editObj(fig, uuid);
    case 'SaveEdits'
        saveEdits(fig);
    case 'CopyUUID'
        copyText(fig);
    case 'PasteUUID'
        pasteText(fig);
    case 'EditSubvar'
        editSubvar(fig);

end