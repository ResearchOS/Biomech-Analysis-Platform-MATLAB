function []=resetProjectAccess_Visibility(fig,visible)

%% PURPOSE: CONSTRAIN THE USER TO ONLY THE PROJECT TAB, AND HIDE NON-ESSENTIAL COMPONENTS ON THAT TAB.
% Inputs:
% fig: The figure object
% visible: Integer from 0 to 3 indicating which subset(s) of components are
% visible

handles=getappdata(fig,'handles');


%% Hide the non-essential components
compNames=fieldnames(handles.Projects); % Get all component names

if visible>=0 % Nothing except for new project components visible
    okTags={'ProjectNameLabel','SwitchProjectsDropDown','AddProjectButton'};
end

if visible>=1 % New project components & code path components visible
    okTags=[okTags, {'CodePathField','OpenCodePathButton','CodePathButton','ArchiveProjectButton'}];
end

if visible>=2 % New project, code path, and data path components visible
    okTags=[okTags, {'DataPathField','OpenDataPathButton','DataPathButton'}];
end

if visible==3 % All Projects tab components visible
    setappdata(fig,'allowAllTabs',1); % Initialize that only the Projects tab can be selected.
else
    setappdata(fig,'allowAllTabs',0); % Initialize that only the Projects tab can be selected.
end

for compNum=1:length(compNames)
    if visible<3
        if ~isequal(handles.Projects.(compNames{compNum}).Tag,'Projects')
            if ~ismember(handles.Projects.(compNames{compNum}).Tag,okTags)
                handles.Projects.(compNames{compNum}).Visible=0;
            else
                handles.Projects.(compNames{compNum}).Visible=1;
            end
        end
    else % All Projects tab components visible.        
        if ~isequal(handles.Projects.(compNames{compNum}).Tag,'Projects')
            handles.Projects.(compNames{compNum}).Visible=1;
        end
    end
end