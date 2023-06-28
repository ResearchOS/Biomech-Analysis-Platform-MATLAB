function []=processResize(src, event)

%% RESIZE THE COMPONENTS WITHIN THE PROCESS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Modify component location
figSize=src.Position(3:4); % Width x height

%% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
if isempty(handles)
    return;
else
    tab=handles.Process;
    fldNames=fieldnames(tab);
    if isequal(fldNames{1},'Tab') && length(fldNames)==1
        return;
    end
end

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(tab.variablesSearchField,'FontSize'); % Get the initial font size
        fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
        setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
    end 
else
    fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
end

% Set new font size
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end

%% Positions specified as relative to tab width & height
% All positions here are specified as relative positions
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
% 1. Variables/function/groups subtab
objResize(tab.subTabAll, [0.01 0.01], [0.33 0.98]);

% 1. Variables label
% objResize(tab.variablesLabel, [0.01 0.8], [0.1 compHeight]);

% 2. Add variable button
objResize(tab.addVariableButton, [0.3 0.7], [0.03 compHeight]);

% 3. Remove variable button
objResize(tab.removeVariableButton, [0.3 0.6], [0.03 compHeight]);

% 4. Sort variables drop down
objResize(tab.sortVariablesDropDown, [0.2 0.85], [0.1 compHeight]);

% 5. All variables UI tree
objResize(tab.allVariablesUITree, [0.01 0.01], [0.29 0.8]);

% 6. Variables search field
objResize(tab.variablesSearchField, [0.01 0.85], [0.15 compHeight]);

% 7. Functions label
% objResize(tab.processLabel, [0.01 0.45], [0.1 compHeight]);

% 8. Add function button
objResize(tab.addProcessButton, [0.3 0.7], [0.03 compHeight]);

% 9. Remove function button
objResize(tab.removeProcessButton, [0.3 0.6], [0.03 compHeight]);

% 10. Sort functions drop down
objResize(tab.sortProcessDropDown, [0.2 0.85], [0.1 compHeight]);

% 11, All functions UI tree
objResize(tab.allProcessUITree, [0.01 0.01], [0.29 0.8]);

% 12. Functions search field
objResize(tab.processSearchField, [0.01 0.85], [0.15 compHeight]);

% 13. Assign variable button
objResize(tab.assignVariableButton, [0.3 0.5], [0.03 compHeight]);

% 14. Unassign variable button
objResize(tab.unassignVariableButton, [0.3 0.4], [0.03 compHeight]);

% 15. Assign function button
objResize(tab.assignFunctionButton, [0.3 0.5], [0.03 compHeight]);

% 16. Unassign function button
objResize(tab.unassignFunctionButton, [0.3 0.4], [0.03 compHeight]);

% 13. Add group button
objResize(tab.addGroupButton, [0.3 0.7], [0.03 compHeight]);

% 14. Remove group button
objResize(tab.removeGroupButton, [0.3 0.6], [0.03 compHeight]);

% 15. Sort group drop down
objResize(tab.sortGroupsDropDown, [0.2 0.85], [0.1 compHeight]);

% 16. All groups UI tree
objResize(tab.allGroupsUITree, [0.01 0.01], [0.29 0.8]);

% 17. Groups search field
objResize(tab.groupsSearchField, [0.01 0.85], [0.15 compHeight]);

% Assign group button
objResize(tab.assignGroupButton, [0.3 0.5], [0.03 compHeight]);

% Unassign group button
objResize(tab.unassignGroupButton, [0.3 0.4], [0.03 compHeight]);

% Add analysis button
objResize(tab.addAnalysisButton, [0.3 0.7], [0.03 compHeight]);

% Remove analysis button
objResize(tab.removeAnalysisButton, [0.3 0.6], [0.03 compHeight]);

% Sort analyses drop down
objResize(tab.sortAnalysesDropDown, [0.2 0.85], [0.1 compHeight]);

% All analyses UI tree
objResize(tab.allAnalysesUITree, [0.01 0.01], [0.29 0.8]);

% Analyses search field
objResize(tab.analysesSearchField, [0.01 0.85], [0.15 compHeight]);



% 18. Queue UI tree
objResize(tab.queueUITree, [0.75 0.35], [0.25 0.6]);

% 19. Queue label
objResize(tab.queueLabel, [0.75 0.95], [0.1 compHeight]);

% 22. Current group/function tab group
objResize(tab.subtabCurrent, [0.35 0.01], [0.4 0.95]);

% 25. Run button
objResize(tab.runButton, [0.9 0.95], [0.05 compHeight]);

% 26. Group UI tree
objResize(tab.groupUITree, [0.01 0.01], [0.35 0.8]);

% 27. Function UI tree
objResize(tab.functionUITree, [0.01 0.01], [0.39 0.8]);

% 28. Analysis UI tree
objResize(tab.analysisUITree, [0.01 0.01], [0.35 0.8]);

% 20. Add to queue button
objResize(tab.addToQueueButton, [0.365 0.75], [0.03 compHeight]);

% 21. Remove from queue button
objResize(tab.removeFromQueueButton, [0.365 0.65], [0.03 compHeight]);

% 30. Save as new group button
objResize(tab.copyToNewAnalysisButton, [0.33 0.1], [0.07 2*compHeight]);

% 31. Select group button
objResize(tab.selectAnalysisButton, [0.3 0.3], [0.03 compHeight]);

% 32. Current group name label
objResize(tab.currentAnalysisLabel, [0.01 0.83], [0.3 compHeight]);

% 33. Add args button
objResize(tab.addArgsButton, [0.3 0.83], [0.03 compHeight]);

% 34. Remove args button
objResize(tab.removeArgsButton, [0.35 0.83], [0.03 compHeight]);

% 35. Add specify trials button
objResize(tab.addSpecifyTrialsButton, [0.8 0.2], [0.03 compHeight]);

% 36. Remove specify trials button
objResize(tab.removeSpecifyTrialsButton, [0.84 0.2], [0.03 compHeight]);

% 37. Specify trials UI tree
objResize(tab.allSpecifyTrialsUITree, [0.8 0.01], [0.19 0.19]);

% 38. Edit specify trials node button
objResize(tab.editSpecifyTrialsButton, [0.9 0.2], [0.1 compHeight]);