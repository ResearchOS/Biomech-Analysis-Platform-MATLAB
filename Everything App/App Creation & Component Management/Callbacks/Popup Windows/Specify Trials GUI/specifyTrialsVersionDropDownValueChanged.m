function []=specifyTrialsVersionDropDownValueChanged(src,specifyTrialsName)

%% PURPOSE: SWITCH ALL SPECIFY TRIALS CRITERIA SHOWING BASED ON PRESET CONFIGURATIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('specifyTrialsName','var')~=1    
    specifyTrialsName=handles.Top.specifyTrialsDropDown.Value;
    runLog=true;
else
    handles.Top.specifyTrialsDropDown.Value=specifyTrialsName;
    runLog=false;
end

pguiFig=evalin('base','gui;');
pguiHandles=getappdata(pguiFig,'handles');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% if ismac==1
%     slash='/';
% elseif ispc==1
%     slash='\';
% end

% tabName=pguiHandles.Tabs.tabGroup1.SelectedTab.Title;

inclStruct=feval(specifyTrialsName);

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

pguiHandles.Process.specifyTrialsLabel.Text=specifyTrialsName;

%% Assign the new specify trials specifyTrialsName to the current function
nodeRow=getappdata(fig,'nodeRow');
% projectSettingsMATPath=getappdata(pguiFig,'projectSettingsMATPath');

% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(pguiFig,'Digraph');
if isequal(specifyTrialsName,Digraph.Nodes.SpecifyTrials{nodeRow})
    runLog=false; % Don't put an entry in the logsheet just for modifying or looking at the specify trials. Has to change the selection to make an entry.
end
Digraph.Nodes.SpecifyTrials{nodeRow}=specifyTrialsName;
% save(projectSettingsMATPath,'Digraph','-append');
setappdata(pguiFig,'Digraph',Digraph);

fcnName=Digraph.Nodes.FunctionNames{nodeRow};
nodeID=Digraph.Nodes.NodeNumber(nodeRow);

if runLog
    desc=['Changed specify trials for function ' fcnName ' node ID #' num2str(nodeID)];
    updateLog(pguiFig,desc,specifyTrialsName);
end