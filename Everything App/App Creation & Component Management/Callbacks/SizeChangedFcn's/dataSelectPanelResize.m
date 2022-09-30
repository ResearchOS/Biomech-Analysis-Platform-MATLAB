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

dataRowCount=getappdata(fig,'dataPanelArrowCount');
dataPanelUpArrowButton=findobj(fig,'Type','uibutton','Tag','DataPanelUpArrowButton');
dataPanelUpArrowButton.Visible='on';
dataPanelDownArrowButton=findobj(fig,'Type','uibutton','Tag','DataPanelDownArrowButton');
dataPanelDownArrowButton.Visible='on';

if dataRowCount>0
    dataRowCount=0; % Protect against clicking up too quickly before the Up arrow visibility is removed.
    setappdata(fig,'dataPanelArrowCount',0);
elseif dataRowCount<-1*loadBoxCount+8 && loadBoxCount>=8 % Protect against clicking down too quickly before the Down arrow visibility is removed.
    dataRowCount=-1*loadBoxCount+8;
    setappdata(fig,'dataPanelArrowCount',dataRowCount);
end

for i=1:length(labels)
    
    % Relative position
    labelRelPos=[0.4 (0.8-(i+dataRowCount)*0.1)];
    loadBoxRelPos=[0.05 (0.8-(i+dataRowCount)*0.1)];
    offloadBoxRelPos=[0.2 (0.8-(i+dataRowCount)*0.1)];
    
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
    
    % Set Visibility
    labels{i}.Visible='on';
    loadBoxes{i}.Visible='on';
    offloadBoxes{i}.Visible='on';
    
    % Set Visibility by Position
    if (0.8-(i+dataRowCount)*0.1)>=0.8 || (0.8-(i+dataRowCount)*0.1)<0 % Outside of the bounds of the panel
        labels{i}.Visible='off';
        loadBoxes{i}.Visible='off';
        offloadBoxes{i}.Visible='off';
    end
    
    if i==1 && (0.8-(i+dataRowCount)*0.1)<0.8 % Turn off visibility for the 'Up' arrow
        dataPanelUpArrowButton.Visible='off';
    end
    if i==loadBoxCount && (0.8-(i+dataRowCount)*0.1)>=0 % Turn off visibility for the 'Down' arrow
        dataPanelDownArrowButton.Visible='off';
    end
    
end