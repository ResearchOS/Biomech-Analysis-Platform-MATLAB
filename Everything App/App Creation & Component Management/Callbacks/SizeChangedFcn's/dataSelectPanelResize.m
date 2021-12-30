function []=dataSelectPanelResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS WITHIN THE DATA SELECT PANEL

data=src.UserData;

if isempty(data)
    return; % Called on uifigure creation
end

% Set components to be invisible

% Modify component location
figSize=src.Position(3:4); % Width x height

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,defaultPos(3:4)) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(data.LogsheetPathField,'FontSize'); % Get the initial font size
        fontSizeRelToHeight=initFontSize/ancSize(2); % Font size relative to figure height.
        setappdata(fig,'fontSizeRelToHeight',fontSizeRelToHeight); % Store the font size relative to figure height.
    end
else
    fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight');
end

% Set new font size
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figure's height

if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text

fldNames=fieldnames(data);
labelCount=0;
loadBoxCount=0;
offloadBoxCount=0;
for i=1:length(fldNames)
    
    currH=data.(fldNames{i});
    if isempty(currH)
        continue;
    end
    currTag=currH.Tag;
    
    if contains(currTag,'ImportTabDataLabel')
        labelCount=labelCount+1;
        labels{labelCount}=currH;
    end
    if contains(currTag,'ImportTabLoadBox')
        loadBoxCount=loadBoxCount+1;
        loadBoxes{loadBoxCount}=currH;
    end
    if contains(currTag,'ImportTabOffloadBox')
        offloadBoxCount=offloadBoxCount+1;
        offloadBoxes{offloadBoxCount}=currH;
    end
    
end

% % Get the set of data label objects
% labels=findobj(src,'-regexp','Tag','ImportTabDataLabel');
% 
% % Get the set of load checkbox objects
% loadBoxes=findobj(src,'-regexp','Tag','ImportTabLoadBox');
% 
% % Get the set of offload checkbox objects
% offloadBoxes=findobj(src,'-regexp','Tag','ImportTabOffloadBox');

for i=1:length(labels)
    
    % Relative position
    labelRelPos=[0.4 (0.8-i*0.1)];
    loadBoxRelPos=[0.05 (0.8-i*0.1)];
    offloadBoxRelPos=[0.2 (0.8-i*0.1)];
    
    % Size
    labelSize=[0.3 compHeight];
    loadBoxSize=[0.1 compHeight];
    offloadBoxSize=[0.1 compHeight];    
    
    % Position
    labelPos=round([labelRelPos.*figSize labelSize(1)*figSize(1) labelSize(2)]);
    loadBoxPos=round([loadBoxRelPos.*figSize loadBoxSize(1)*figSize(1) loadBoxSize(2)]);
    offloadBoxPos=round([offloadBoxRelPos.*figSize offloadBoxSize(1)*figSize(1) offloadBoxSize(2)]);    
    
    % Set Position
    labels{i}.Position=labelPos;
    loadBoxes{i}.Position=loadBoxPos;
    offloadBoxes{i}.Position=offloadBoxPos;
    
    % Set Font Size
    labels{i}.FontSize=newFontSize;
    loadBoxes{i}.FontSize=newFontSize;
    offloadBoxes{i}.FontSize=newFontSize;
    
end