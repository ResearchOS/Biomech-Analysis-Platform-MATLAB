function settingsResize(tab, compHeight, fontSize, figSize)

%% PURPOSE: RESIZE THE COMPONENTS IN THE PROJECTS TAB.
% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');
% 
% figSize=fig.Position(3:4); % Width x height. Used by objResize function
% 
% %% Check if called on uifigure creation. If so, skip resizing components because they don't exist yet.
% if isempty(handles)
%     return;
% else
%     tab=handles.Settings;
%     fldNames=fieldnames(tab);
%     if isequal(fldNames{1},'Tab') && length(fldNames)==1
%         return;
%     end
% end
% 
% %% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
% ancSize=fig.Position(3:4);
% defaultPos=get(0,'defaultfigureposition');
% if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
%     if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
%         fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
%     else % Figure initialized as default size
%         initFontSize=get(tab.dbFilePathEditField,'FontSize'); % Get the initial font size
%         fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
%         setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
%     end 
% else
%     fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
% end
% 
% %% Set new font size & component height
% newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
% if newFontSize>20
%     newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
% end
% 
% compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}

% 1. Select common path button
objResize(tab.dbFilePathButton, [0.01 0.9], [0.1 compHeight]);

% 3. Common path edit field
objResize(tab.dbFilePathEditField, [0.12 0.9], [0.2 compHeight]);

% 4. Open common path button
objResize(tab.opendbFilePathButton, [0.33 0.9], [0.05 compHeight]);

% 5. Store settings checkbox
% objResize(tab.storeSettingsCheckbox, [0.8 0.9], [0.2 compHeight]);