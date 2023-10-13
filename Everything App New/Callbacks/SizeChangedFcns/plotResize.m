function [fontSizeRelToHeight]=plotResize(tab,compHeight, fontSize, figSize)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE PLOT TAB

% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');
% 
% % Modify component location
% figSize=src.Position(3:4); % Width x height
% 
% %% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
% if isempty(handles)
%     return;
% else
%     tab=handles.Plot;
%     fldNames=fieldnames(tab);
%     if isequal(fldNames{1},'Tab') && length(fldNames)==1
%         return;
%     end
% end
% 
% % Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
% fig=ancestor(src,'figure','toplevel');
% ancSize=fig.Position(3:4);
% defaultPos=get(0,'defaultFigurePosition');
% if isequal(ancSize,defaultPos(3:4)) % If currently in default figure size
%     if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
%         fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
%     else % Figure initialized as default size
%         initFontSize=get(tab.plotSearchField,'FontSize'); % Get the initial font size
%         fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
%         setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
%     end 
% else
%     fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
% end
% 
% % Set new font size
% newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
% if newFontSize>20
%     newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
% end
% 
% %% Positions specified as relative to tab width & height
% compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
% All positions here are specified as relative positions
% 1. Variables/components/plots subtab
objResize(tab.subTabAll, [0.01 0.01], [0.33 0.98]);

% 1. Plot label
% objResize(tab.plotLabel, [0.01 0.95], [0.1 compHeight]);

% 2. Add plot button
objResize(tab.addPlotButton, [0.3 0.7], [0.03 compHeight]);

% 3. Remove plot button
objResize(tab.removePlotButton, [0.3 0.6], [0.03 compHeight]);

% 4. Sort plots drop down
objResize(tab.sortPlotsDropDown, [0.2 0.85], [0.1 compHeight]);

% 5. All plots UI tree
objResize(tab.allPlotsUITree, [0.01 0.01], [0.29 0.8]);

% 6. Plots search field
objResize(tab.plotSearchField, [0.01 0.85], [0.15 compHeight]);

% 7. Component label
% objResize(tab.componentLabel, [0.01 0.45], [0.1 compHeight]);

% 8. Assign plot button
objResize(tab.assignPlotButton, [0.3 0.5], [0.03 compHeight]);

% 9. Unassign plot button
objResize(tab.unassignPlotButton, [0.3 0.4], [0.03 compHeight]);

% 8. Add component button
objResize(tab.addComponentButton, [0.3 0.7], [0.03 compHeight]);

% 9. Remove component button
objResize(tab.removeComponentButton, [0.3 0.6], [0.03 compHeight]);

% 10. Sort components drop down
objResize(tab.sortComponentsDropDown, [0.2 0.85], [0.1 compHeight]);

% 11. All components UI tree
objResize(tab.allComponentsUITree, [0.01 0.01], [0.29 0.8]);

% 12. Components search field
objResize(tab.componentSearchField, [0.01 0.85], [0.15 compHeight]);

% 13. Assign component button
objResize(tab.assignComponentButton, [0.3 0.5], [0.03 compHeight]);

% 14. Unassign component button
objResize(tab.unassignComponentButton, [0.3 0.4], [0.03 compHeight]);

% 15. Current plot/component tab group
objResize(tab.subtabCurrent, [0.35 0.01], [0.4 0.95]);

% 16. Render button
objResize(tab.plotButton, [0.9 0.95], [0.05 compHeight]);

% 17. Plot UI tree
objResize(tab.plotUITree, [0.01 0.01], [0.35 0.8]);

% 18. Component UI tree
objResize(tab.componentUITree, [0.01 0.01], [0.35 0.8]);

% 19. Save as new plot button
objResize(tab.saveAsNewPlotButton, [0.33 0.1], [0.07 2*compHeight]);

% 20. Select plot button
objResize(tab.selectPlotButton, [0.3 0.3], [0.03 compHeight]);

% 21. Current plot name label
objResize(tab.currentPlotLabel, [0.01 0.83], [0.3 compHeight]);

% 22. Add specify trials button
objResize(tab.addSpecifyTrialsButton, [0.8 0.2], [0.03 compHeight]);

% 23. Remove specify trials button
objResize(tab.removeSpecifyTrialsButton, [0.84 0.2], [0.03 compHeight]);

% 24. Specify trials UI tree
objResize(tab.allSpecifyTrialsUITree, [0.8 0.01], [0.19 0.19]);

% 25. Edit specify trials node button
objResize(tab.editSpecifyTrialsButton, [0.9 0.2], [0.1 compHeight]);

% 26. Add args button
objResize(tab.addArgsButton, [0.3 0.83], [0.03 compHeight]);

% 27. Remove args button
objResize(tab.removeArgsButton, [0.35 0.83], [0.03 compHeight]);

% 27. Properties UI tree
objResize(tab.propertiesUITree, [0.01 0.01], [0.35 0.8]);

% 28. Edit property text area
objResize(tab.editPropertyTextArea, [0.01 0.01], [0.1 compHeight]);
