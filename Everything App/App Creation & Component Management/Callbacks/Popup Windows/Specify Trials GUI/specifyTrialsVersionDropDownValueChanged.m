function []=specifyTrialsVersionDropDownValueChanged(src,event)

%% PURPOSE: SWITCH ALL SPECIFY TRIALS CRITERIA SHOWING BASED ON PRESET CONFIGURATIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

name=handles.Top.specifyTrialsDropDown.Value;

pguiFig=evalin('base','gui;');
% pguiHandles=getappdata(pguiFig,'handles');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% if ismac==1
%     slash='/';
% elseif ispc==1
%     slash='\';
% end

% tabName=pguiHandles.Tabs.tabGroup1.SelectedTab.Title;

inclStruct=feval(name);

% Parse the inclStruct to populate the GUI.
currSelectedTab=handles.Top.includeExcludeTabGroup.SelectedTab;
for inclExcl=1:2

    switch inclExcl
        case 1
            type='Include';  
            currTab=handles.Top.includeTab;    
        case 2
            type='Exclude';
            currTab=handles.Top.excludeTab;    
    end    

    currCondDropDown=handles.(type).conditionDropDown;

    if ~isstruct(inclStruct) || ~isfield(inclStruct,'Include')
        disp('No trials to include');
        condNames={'Add Condition Name'};
        currCondDropDown.Items=condNames;
        currCondDropDown.Value=condNames{1};

        conditionNameDropDownValueChanged(currCondDropDown); % Propagate the changes
        return;
    end

    if ~isfield(inclStruct,type)
        continue;
    end

    currStruct=inclStruct.(type);

    condNames=cell(length(currStruct.Condition),1);

    for condNum=1:length(currStruct.Condition)
        condNames{condNum}=currStruct.Condition(condNum).Name;        
    end

    currCondDropDown.Items=condNames;
    currCondDropDown.Value=condNames{1};

    handles.Top.includeExcludeTabGroup.SelectedTab=currTab;

    conditionNameDropDownValueChanged(currCondDropDown); % Propagate the changes

end

handles.Top.includeExcludeTabGroup.SelectedTab=currSelectedTab;

%% Assign the new specify trials name to the current function
nodeRow=getappdata(fig,'nodeRow');
projectSettingsMATPath=getappdata(pguiFig,'projectSettingsMATPath');

load(projectSettingsMATPath,'Digraph');
Digraph.Nodes.SpecifyTrials{nodeRow}=name;
save(projectSettingsMATPath,'Digraph','-append');