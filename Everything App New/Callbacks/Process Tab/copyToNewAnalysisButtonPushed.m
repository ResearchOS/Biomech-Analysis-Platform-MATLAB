function [] = copyToNewAnalysisButtonPushed(src,event)

%% PURPOSE: COPY THE OBJECTS IN THE CURRENT ANALYSIS TO A NEW ANALYSIS, AND SELECT THAT NEW ANALYSIS.

global conn;


    

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
[type,abstractID] = deText(Current_Analysis);
prevAbstractUUID = genUUID(type, abstractID);

name = promptName('New Analysis','Default');

anStruct = createNewObject(true, 'Analysis', name, abstractID, '', true);

%% 1. Link analysis to project.
linkObjs(anStruct.UUID,getCurrent('Current_Project_Name'));

%% 2. Get all analysis views, PR, and PG.
sqlquery = ['SELECT VW_ID FROM AN_VW WHERE AN_ID = ''' Current_Analysis ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if isempty(fieldnames(t))
    vwUUID = {};
else
    if ~iscell(t.VW_ID)
        t.VW_ID = {t.VW_ID};
    end
    vwUUID = t.VW_ID;
end

sqlquery = ['SELECT PG_ID FROM AN_PG WHERE AN_ID = ''' Current_Analysis ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if isempty(fieldnames(t))
    pgUUID = {};
else
    if ~iscell(t.PG_ID)
        t.PG_ID = {t.PG_ID};
    end
    pgUUID = t.PG_ID;
end

sqlquery = ['SELECT PR_ID FROM AN_PR WHERE AN_ID = ''' Current_Analysis ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if isempty(fieldnames(t))
    prUUID = {};
else
    if ~iscell(t.PR_ID)
        t.PR_ID = {t.PR_ID};
    end
    prUUID = t.PR_ID;
end

%% 3. Link them to the new analysis.
linkObjs(vwUUID, anStruct.UUID);
linkObjs(pgUUID, anStruct.UUID);
linkObjs(prUUID, anStruct.UUID);

%% 4. Make the new analysis the current analysis, and select it.
setCurrent('Current_Analysis', anStruct.UUID);
abstractNode = getNode(handles.Process.allAnalysesUITree, prevAbstractUUID);
newNode = addNewNode(abstractNode, anStruct.UUID);
handles.Process.allAnalysesUITree.SelectedNodes = newNode;
selectAnalysisButtonPushed(fig);