function []=resetProjectAccess_Visibility(fig,visible)

%% PURPOSE: CONSTRAIN THE USER TO ONLY THE PROJECT TAB, AND HIDE NON-ESSENTIAL COMPONENTS ON THAT TAB.
% Inputs:
% fig: The figure object
% visible: Integer from 0 to 3 indicating which subset(s) of components are
% 0-2: Projects tab only, no others
% 0: Projects drop down only
% 1: Code path & projects drop down only
% 2: Data path, code path, & projects drop down only
% 3: Projects & Import tabs only, showing only the logsheet header info
% objects
% 4: All tabs, all objects on those tabs.

handles=getappdata(fig,'handles');

compNamesProjects=fieldnames(handles.Projects); % Get all component names for Projects tab
compNamesImport=fieldnames(handles.Import); % Get all component names for Import tab

okTagsProjects={};
okTagsImport={};

%% Assign tags of components that should be visible
if visible>=0 % Nothing except for new project components visible
    okTagsProjects=[okTagsProjects, {'OpenPISettingsPathButton','ProjectNameLabel','SwitchProjectsDropDown','AddProjectButton'}];
end

if visible>=1 % New project components & code path components visible
    okTagsProjects=[okTagsProjects, {'CodePathField','OpenCodePathButton','CodePathButton','ArchiveProjectButton'}];
end

if visible>=2 % New project, code path, and data path components visible
    okTagsProjects=[okTagsProjects, {'DataPathField','OpenDataPathButton','DataPathButton'}];
end

if visible>=3 % Logsheet header info components visible on Import tab
    okTagsImport=[okTagsImport, {'LogsheetPathButton','LogsheetPathField','LogsheetLabel','NumHeaderRowsLabel','NumHeaderRowsField','SubjectIDColumnHeaderLabel',...
        'SubjIDColumnHeaderField','TrialIDColHeaderDataTypeLabel','DataTypeTrialIDColumnHeaderField','TargetTrialIDColHeaderLabel','TargetTrialIDColHeaderField','OpenLogsheetButton'}];
end

if visible>=4 % Logsheet data components visible on Import tab
    okTagsImport=[okTagsImport, {}];
end

%% Assign "allowAllTabs" variable for tabGroup1SelectionChanged
if ismember(visible,[0 1 2]) % Projects tab only
    allowAllTabs=0;
elseif visible==3 % Projects & Import tabs only
    allowAllTabs=1;
elseif visible==4 % All tabs
    allowAllTabs=2;
end

setappdata(fig,'allowAllTabs',allowAllTabs);

%% Hide the "not ok" components
if allowAllTabs<=1 % Projects tab only
    for compNum=1:length(compNamesProjects)
        if ~isequal(handles.Projects.(compNamesProjects{compNum}).Tag,'Projects')
            if ~ismember(handles.Projects.(compNamesProjects{compNum}).Tag,okTagsProjects)
                handles.Projects.(compNamesProjects{compNum}).Visible=0;
            else
                handles.Projects.(compNamesProjects{compNum}).Visible=1;
            end
        end
    end
end

if allowAllTabs<2 % Projects & Import tabs only
    for compNum=1:length(compNamesImport)
        if ~isequal(handles.Import.(compNamesImport{compNum}).Tag,'Import')
            if ~ismember(handles.Import.(compNamesImport{compNum}).Tag,okTagsImport)
                handles.Import.(compNamesImport{compNum}).Visible=0;
            else
                handles.Import.(compNamesImport{compNum}).Visible=1;
            end
        end
    end
end

if allowAllTabs==2 % All tabs
    for compNum=1:length(compNamesProjects)
        if ~isequal(handles.Projects.(compNamesProjects{compNum}).Tag,'Projects')
            handles.Projects.(compNamesProjects{compNum}).Visible=1; % Turn on visibility for all Projects tab components
        end
    end

    for compNum=1:length(compNamesImport)
        if ~isequal(handles.Import.(compNamesImport{compNum}).Tag,'Import')
            handles.Import.(compNamesImport{compNum}).Visible=1; % Turn on visibility for all Import tab components
        end
    end
end