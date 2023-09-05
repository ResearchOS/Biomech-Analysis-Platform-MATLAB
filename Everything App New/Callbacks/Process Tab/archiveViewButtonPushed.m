function []=archiveViewButtonPushed(src,event)

%% PURPOSE: DELETE THE CURRENT VIEW (IRREVERSIBLE). CANNOT DELETE THE ALL VIEW

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uuid = handles.Process.viewsDropDown.Value;

[type, abstractID] = deText(uuid);

if isequal(abstractID,repmat('0',1,length(abstractID)))
    return; % Cannot delete the 'ALL' view.
end

anList = getAnalysis(uuid);
Current_Analysis = getCurrent('Current_Analysis');
unlinkObjs(Current_Analysis, uuid);

%% Remove the view from the current drop down list.
currIdx = ismember(handles.Process.viewsDropDown.ItemsData,uuid);
handles.Process.viewsDropDown.Items(currIdx) = [];

allIdx = contains(handles.Process.viewsDropDown.ItemsData,repmat('0',1,length(abstractID)));
handles.Process.viewsDropDown.Value = handles.Process.viewsDropDown.Items{allIdx};

% Check if this view exists in any other analyses.
anList(ismember(anList,Current_Analysis)) = [];

if isempty(anList)
   sqlquery = ['DELETE FROM Views_Instances WHERE UUID = ''' uuid ''';'];
   execute(conn, sqlquery);
end