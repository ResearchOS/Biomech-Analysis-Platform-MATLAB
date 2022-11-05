function []=includeUpArrowButtonPushed(src, event)

%% PURPOSE: MOVE THE ENTRIES IN THE INCLUSION CRITERIA TAB UP  ONE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

rowCountStruct=getappdata(fig,'rowCountStruct');

% Get the specify trials version name.
vName=handles.Top.specifyTrialsDropDown.Value;

% Get whether this is inclusion or exclusion tab
inclExclTab=handles.Top.includeExcludeTabGroup.SelectedTab;
tabName=inclExclTab.Title;

% Get the condition name
condName=handles.(tabName).conditionDropDown.Value;

% Get whether this is logsheet or struct
logOrStruct=handles.(tabName).logStructTabGroup.SelectedTab;
logOrStruct=logOrStruct.Title;

if existField(rowCountStruct,['rowCountStruct.' vName '.' tabName '.' condName '.' logOrStruct])
    prevArrowCount=rowCountStruct.(vName).(tabName).(condName).(logOrStruct);
else
    prevArrowCount=0;
end

rowCountStruct.(vName).(tabName).(condName).(logOrStruct)=prevArrowCount+1;

setappdata(fig,'rowCountStruct',rowCountStruct);

if isequal(logOrStruct,'Logsheet')
    logsheetTabResize(fig);
elseif isequal(logOrStruct,'Structure')
    structureTabResize(fig);
end