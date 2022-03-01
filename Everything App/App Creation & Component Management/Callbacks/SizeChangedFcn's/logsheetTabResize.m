function []=logsheetTabResize(src)

%% PURPOSE: RESIZE THE COMPONENTS IN THE LOGSHEET TAB (INCLUSION OR EXCLUSION). SIMILAR TO runGroupNameDropDownValueChanged IN PGUI

data=src.UserData;
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(data)
    return;
end

figSize=fig.Position(3:4); % Width x height

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
dropdownCount=0;
editfieldCount=0;
for i=1:length(fldNames)

    currH=data.(fldNames{i});
    if isempty(currH) || ~isvalid(currH)
        continue;
    end
    if contains(fldNames{i},'Labels')
        labelCount=labelCount+1;
        labels(labelCount)=currH;
    elseif contains(fldNames{i},'DropDown')
        dropdownCount=dropdownCount+1;
        dropdowns(dropdownCount)=currH;
    elseif contains(fldNames{i},'TextField')
        editfieldCount=editfieldCount+1;
        editfields(editfieldCount)=currH;
    end

end

% The up/down arrow count will be specific to specify trials version number, include/exclude tab,
% condition number, & logsheet/struct tab.
rowCountStruct=getappdata(fig,'rowCountStruct');

% Get the specify trials version name.
vName=handles.Top.specifyTrialsDropDown.Value;

% Get whether this is inclusion or exclusion tab
inclExclTab=handles.Top.includeExcludeTabGroup.SelectedTab;
tabName=inclExclTab.Title;

% Get the condition name
condName=handles.(tabName).conditionDropDown.Value;

% Get whether this is logsheet or struct
logOrStruct=handles.(tabName).logStructTabGroup.SelectedTab;
logOrStruct=logOrStruct.Title;

% Get the up and down arrow handles
upArrow=handles.(tabName).UpArrowButton;
downArrow=handles.(tabName).DownArrowButton;

if existField(rowCountStruct,['rowCountStruct.' vName '.' tabName '.' condName '.' logOrStruct])
    currArrowCount=rowCountStruct.(vName).(tabName).(condName).(logOrStruct);
else
    currArrowCount=0;
end

for i=1:length(labels)

    % Relative positions
    labelsRelPos=[0.02 0.75-(i+currArrowCount)*0.1];
    dropdownsRelPos=[0.25 0.75-(i+currArrowCount)*0.1];
    editfieldsRelPos=[0.5 0.75-(i+currArrowCount)*0.1];

    % Size
    labelsSize=[0.2 compHeight];
    dropdownsSize=[0.2 compHeight];
    editfieldsSize=[0.4 compHeight];

    % Position
    labelsPos=round([labelsRelPos.*figSize labelsSize(1)*figSize(1) labelsSize(2)]);
    dropdownPos=round([dropdownsRelPos.*figSize dropdownsSize(1)*figSize(1) dropdownsSize(2)]);
    editfieldsPos=round([editfieldsRelPos.*figSize editfieldsSize(1)*figSize(1) editfieldsSize(2)]);

    % Set Position
    labels(i).Position=labelsPos;
    dropdowns(i).Position=dropdownPos;
    editfields(i).Position=editfieldsPos;

    % Set Font Size
    labels(i).FontSize=newFontSize;
    dropdowns(i).FontSize=newFontSize;
    editfields(i).FontSize=newFontSize;

    % Set Visibility
    labels(i).Visible='on';
    dropdowns(i).Visible='on';
    editfields(i).Visible='on';

    % Set Visibility by Position
    if 0.75-(i-1)*0.1<=0
        labels(i).Visible='off';
        dropdowns(i).Visible='off';
        editfields(i).Visible='off';
    end

    if i==1 && (0.75-(i+currArrowCount)*0.1)<0.75 % Turn off visibility for the 'Up' arrow
        upArrow.Visible='off';
    end
    if i==length(labels) && (0.75-(i+currArrowCount)*0.1)>0 % Turn off visibility for the 'Down' arrow
        downArrow.Visible='off';
    end

end