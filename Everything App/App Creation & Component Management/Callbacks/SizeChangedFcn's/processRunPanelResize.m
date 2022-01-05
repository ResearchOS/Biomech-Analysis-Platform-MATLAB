function []=processRunPanelResize(src, event)

%% PURPOSE: RESIZE THE PANEL IN THE PROCESS > RUN PANEL

data=src.UserData;

if isempty(data)
    return; % Called on uifigure creation
end

figSize=src.Position(3:4); % Width x height

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
runFcnCheckboxCount=0;
openFcnButtonCount=0;
fcnArgsButtonCount=0;
specifyTrialsCheckboxCount=0;
specifyTrialsButtonCount=0;
for i=1:length(fldNames)
    
    currH=data.(fldNames{i});
    if isempty(currH) || ~isvalid(currH)
        continue;
    end
    currTag=currH.Tag;
    
    if contains(currTag,'RunFcnCheckbox')
        runFcnCheckboxCount=runFcnCheckboxCount+1;
        runFcnCheckbox(runFcnCheckboxCount)=currH;
    end
    if contains(currTag,'OpenFcnButton')
        openFcnButtonCount=openFcnButtonCount+1;
        openFcnButton(openFcnButtonCount)=currH;
    end
    if contains(currTag,'FcnArgsButton')
        fcnArgsButtonCount=fcnArgsButtonCount+1;
        fcnArgsButton(fcnArgsButtonCount)=currH;
    end
    if contains(currTag,'SpecifyTrialsCheckbox')
        specifyTrialsCheckboxCount=specifyTrialsCheckboxCount+1;
        specifyTrialsCheckbox(specifyTrialsCheckboxCount)=currH;
    end
    if contains(currTag,'SpecifyTrialsButton')
        specifyTrialsButtonCount=specifyTrialsButtonCount+1;
        specifyTrialsButton(specifyTrialsButtonCount)=currH;
    end
    
end

fcnRowCount=getappdata(fig,'processRunArrowCount');
processRunUpArrowButton=findobj(fig,'Type','uibutton','Tag','ProcessRunUpArrowButton');
processRunUpArrowButton.Visible='on';
processRunDownArrowButton=findobj(fig,'Type','uibutton','Tag','ProcessRunDownArrowButton');
processRunDownArrowButton.Visible='on';

if fcnRowCount>0
    fcnRowCount=0; % Protect against clicking up too quickly before the Up arrow visibility is removed.
    setappdata(fig,'processRunArrowCount',0);
elseif fcnRowCount<-1*specifyTrialsButtonCount+9 && specifyTrialsButtonCount>=9 % Protect against clicking down too quickly before the Down arrow visibility is removed.
    fcnRowCount=-1*specifyTrialsButtonCount+9;
    setappdata(fig,'processRunArrowCount',fcnRowCount);
end

for i=1:specifyTrialsButtonCount
    
    % Relative position
    runFcnCheckboxRelPos=[0.03 (1-(i+fcnRowCount)*0.1)];
    openFcnButtonRelPos=[0.08 (1-(i+fcnRowCount)*0.1)];
    fcnArgsButtonRelPos=[0.5 (1-(i+fcnRowCount)*0.1)];
    specifyTrialsCheckboxRelPos=[0.7 (1-(i+fcnRowCount)*0.1)];
    specifyTrialsButtonRelPos=[0.75 (1-(i+fcnRowCount)*0.1)];
    
    % Size
    runFcnCheckboxSize=[0.05 compHeight];
    openFcnButtonSize=[0.35 compHeight];
    fcnArgsButtonSize=[0.1 compHeight];
    specifyTrialsCheckboxSize=[0.05 compHeight];
    specifyTrialsButtonSize=[0.2 compHeight];
    
    % Position
    runFcnCheckboxPos=round([runFcnCheckboxRelPos.*figSize runFcnCheckboxSize(1)*figSize(1) runFcnCheckboxSize(2)]);
    openFcnButtonPos=round([openFcnButtonRelPos.*figSize openFcnButtonSize(1)*figSize(1) openFcnButtonSize(2)]);
    fcnArgsButtonPos=round([fcnArgsButtonRelPos.*figSize fcnArgsButtonSize(1)*figSize(1) fcnArgsButtonSize(2)]);
    specifyTrialsCheckboxPos=round([specifyTrialsCheckboxRelPos.*figSize specifyTrialsCheckboxSize(1)*figSize(1) specifyTrialsCheckboxSize(2)]);
    specifyTrialsButtonPos=round([specifyTrialsButtonRelPos.*figSize specifyTrialsButtonSize(1)*figSize(1) specifyTrialsButtonSize(2)]);
    
    % Set Position
    runFcnCheckbox(i).Position=runFcnCheckboxPos;
    openFcnButton(i).Position=openFcnButtonPos;
    fcnArgsButton(i).Position=fcnArgsButtonPos;
    specifyTrialsCheckbox(i).Position=specifyTrialsCheckboxPos;
    specifyTrialsButton(i).Position=specifyTrialsButtonPos;
    
    % Set Font Size
    runFcnCheckbox(i).FontSize=newFontSize;
    openFcnButton(i).FontSize=newFontSize;
    fcnArgsButton(i).FontSize=newFontSize;
    specifyTrialsCheckbox(i).FontSize=newFontSize;
    specifyTrialsButton(i).FontSize=newFontSize;
    
    % Set Visibility
    runFcnCheckbox(i).Visible='on';
    openFcnButton(i).Visible='on';
    fcnArgsButton(i).Visible='on';
    specifyTrialsCheckbox(i).Visible='on';
    specifyTrialsButton(i).Visible='on';
    
    % Set Visibility by Position
    if (1-(i+fcnRowCount)*0.1)>=1 || (1-(i+fcnRowCount)*0.1)<=0 % Outside of the bounds of the panel
        runFcnCheckbox(i).Visible='off';
        openFcnButton(i).Visible='off';
        fcnArgsButton(i).Visible='off';
        specifyTrialsCheckbox(i).Visible='off';
        specifyTrialsButton(i).Visible='off';
    end
    
    if i==1 && (1-(i+fcnRowCount)*0.1)<1 % Turn off visibility for 'Up' arrow
        processRunUpArrowButton.Visible='off';
    end
    if i==specifyTrialsButtonCount && (1-(i+fcnRowCount)*0.1)>0 % Turn off visiiblity for 'Down' arrow
        processRunDownArrowButton.Visible='off';
    end
    
    % Set Visibility by Checkboxes
    if runFcnCheckbox(i).Value==0 % If not checked, turn off specify trials checkbox & button visibility
        specifyTrialsCheckbox(i).Visible='off';
        specifyTrialsButton(i).Visible='off';
    elseif isequal(runFcnCheckbox(i).Visible,'on')
        specifyTrialsCheckbox(i).Visible='on';
        specifyTrialsButton(i).Visible='on';
    end
    if specifyTrialsCheckbox(i).Value==1 && specifyTrialsCheckbox(i).Visible==1 % If not checked, turn off specify trials button visibility
        specifyTrialsButton(i).Visible='on';
    else
        specifyTrialsButton(i).Visible='off';
    end
    
end