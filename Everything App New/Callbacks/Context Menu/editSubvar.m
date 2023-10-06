function [] = editSubvar(src,vrUUID)

%% PURPOSE: EDIT THE SUBVARIABLE FOR THE SELECTED VARIABLE.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

if isempty(selNode)
    return;
end

if nargin==1 || ~ischar(vrUUID)
    vrUUID = selNode.NodeData.UUID;
end

type = deText(vrUUID);
if ~isequal(type,'VR') || isempty(vrUUID)
    return;
end

selPRNode = handles.Process.groupUITree.SelectedNodes;
if isempty(selPRNode)
    return;
end

prUUID = selPRNode.NodeData.UUID;

text = selNode.Text;
nameInCode = strsplit(text,' ');
nameInCode = nameInCode{1};

sqlquery = ['SELECT Subvariable FROM VR_PR WHERE PR_ID = ''' prUUID ''' AND VR_ID = ''' vrUUID ''' AND NameInCode = ''' nameInCode ''';'];
t = fetchQuery(sqlquery);
if isempty(t.Subvariable)
    return;
end

subvar = t.Subvariable;

a = inputdlg('Specify subvariable','Subvariable',[1 45],{subvar});
if isempty(a)
    return;
end
a = a{1};

sqlquery = ['UPDATE VR_PR SET Subvariable = ''' a ''' WHERE PR_ID = ''' prUUID ''' AND VR_ID = ''' vrUUID ''' AND NameInCode = ''' nameInCode ''';'];
execute(conn, sqlquery);