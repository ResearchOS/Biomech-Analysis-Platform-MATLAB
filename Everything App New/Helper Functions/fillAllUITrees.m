function [] = fillAllUITrees(src)

%% PURPOSE: FILL ALL OF THE UI TREES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Fill the "ALL" UI trees with objects from the current analysis.
sortDropDowns=[handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Process.sortGroupsDropDown; handles.Import.sortLogsheetsDropDown; handles.Process.sortAnalysesDropDown];
uiTrees=[handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Process.allGroupsUITree; handles.Import.allLogsheetsUITree; handles.Process.allAnalysesUITree];
classNamesUITrees={'Variable','Process',...
    'ProcessGroup','Logsheet','Analysis'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
end

fillUITree_SpecifyTrials(fig); % Fill in the specify trials