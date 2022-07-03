function []=projectsResize(src, event)

%% PURPOSE: RESIZE THE COMPONENTS IN THE PROJECTS TAB.

data=src.UserData; % Get UserData to access components.
if isempty(data)
    return; % Called on uifigure creation
end

% Modify component location
figSize=src.Position(3:4); % Width x height

% Identify the ratio of font size to figure height (will likely be different for each computer). Used to scale the font size.
fig=ancestor(src,'figure','toplevel');
ancSize=fig.Position(3:4);
defaultPos=get(0,'defaultfigureposition');
if isequal(ancSize,[defaultPos(3)*2 defaultPos(4)]) % If currently in default figure size
    if ~isempty(getappdata(fig,'fontSizeRelToHeight')) % If the figure has been restored to default size after previously being resized.
        fontSizeRelToHeight=getappdata(fig,'fontSizeRelToHeight'); % Get the original ratio.
    else % Figure initialized as default size
        initFontSize=get(data.DataPathField,'FontSize'); % Get the initial font size
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
ProjectNameLabelRelPos=[0.01 0.95];
DataPathButtonRelPos=[0.01 0.85];
CodePathButtonRelPos=[0.01 0.9];
AddProjectButtonRelPos=[0.37 0.95];
DataPathFieldRelPos=[0.17 0.85];
CodePathFieldRelPos=[0.17 0.9];
SwitchProjectsDropDownRelPos=[0.17 0.95];
ArchiveProjectButtonRelPos=[0.43 0.95];
OpenDataPathButtonRelPos=[0.37 0.85];
OpenCodePathButtonRelPos=[0.37 0.9];
UnarchiveProjectButtonRelPos=[0.43 0.9];
OpenPISettingsPathButtonRelPos=[0.7 0.95];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
ProjectNameLabelSize=[0.15 compHeight];
DataPathButtonSize=[0.15 compHeight];
CodePathButtonSize=[0.15 compHeight];
AddProjectButtonSize=[0.05 compHeight];
DataPathFieldSize=[0.2 compHeight];
CodePathFieldSize=[0.2 compHeight];
SwitchProjectsDropDownSize=[0.2 compHeight];
ArchiveProjectButtonSize=[0.06 compHeight];
OpenDataPathButtonSize=[0.05 compHeight];
OpenCodePathButtonSize=[0.05 compHeight];
UnarchiveProjectButtonSize=[0.06 compHeight];
OpenPISettingsPathButtonSize=[0.15 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
ProjectNameLabelPos=round([ProjectNameLabelRelPos.*figSize ProjectNameLabelSize(1)*figSize(1) ProjectNameLabelSize(2)]);
DataPathButtonPos=round([DataPathButtonRelPos.*figSize DataPathButtonSize(1)*figSize(1) DataPathButtonSize(2)]);
CodePathButtonPos=round([CodePathButtonRelPos.*figSize CodePathButtonSize(1)*figSize(1) CodePathButtonSize(2)]);
AddProjectButtonPos=round([AddProjectButtonRelPos.*figSize AddProjectButtonSize(1)*figSize(1) AddProjectButtonSize(2)]);
DataPathFieldPos=round([DataPathFieldRelPos.*figSize DataPathFieldSize(1)*figSize(1) DataPathFieldSize(2)]);
CodePathFieldPos=round([CodePathFieldRelPos.*figSize CodePathFieldSize(1)*figSize(1) CodePathFieldSize(2)]);
OpenDataPathButtonPos=round([OpenDataPathButtonRelPos.*figSize OpenDataPathButtonSize(1)*figSize(1) OpenDataPathButtonSize(2)]);
OpenCodePathButtonPos=round([OpenCodePathButtonRelPos.*figSize OpenCodePathButtonSize(1)*figSize(1) OpenCodePathButtonSize(2)]);
ArchiveProjectButtonPos=round([ArchiveProjectButtonRelPos.*figSize ArchiveProjectButtonSize(1)*figSize(1) ArchiveProjectButtonSize(2)]);
UnarchiveProjectButtonPos=round([UnarchiveProjectButtonRelPos.*figSize UnarchiveProjectButtonSize(1)*figSize(1) UnarchiveProjectButtonSize(2)]);
SwitchProjectsDropDownPos=round([SwitchProjectsDropDownRelPos.*figSize SwitchProjectsDropDownSize(1)*figSize(1) SwitchProjectsDropDownSize(2)]);
OpenPISettingsPathButtonPos=round([OpenPISettingsPathButtonRelPos.*figSize OpenPISettingsPathButtonSize(1)*figSize(1) OpenPISettingsPathButtonSize(2)]);

data.ProjectNameLabel.Position=ProjectNameLabelPos;
data.DataPathButton.Position=DataPathButtonPos;
data.CodePathButton.Position=CodePathButtonPos;
data.AddProjectButton.Position=AddProjectButtonPos;
data.DataPathField.Position=DataPathFieldPos;
data.CodePathField.Position=CodePathFieldPos;
data.OpenDataPathButton.Position=OpenDataPathButtonPos;
data.OpenCodePathButton.Position=OpenCodePathButtonPos;
data.ArchiveProjectButton.Position=ArchiveProjectButtonPos;
data.UnarchiveProjectButton.Position=UnarchiveProjectButtonPos;
data.SwitchProjectsDropDown.Position=SwitchProjectsDropDownPos;
data.OpenPISettingsPathButton.Position=OpenPISettingsPathButtonPos;

data.ProjectNameLabel.FontSize=newFontSize;
data.DataPathButton.FontSize=newFontSize;
data.CodePathButton.FontSize=newFontSize;
data.AddProjectButton.FontSize=newFontSize;
data.DataPathField.FontSize=newFontSize;
data.CodePathField.FontSize=newFontSize;
data.SwitchProjectsDropDown.FontSize=newFontSize;
data.OpenDataPathButton.FontSize=newFontSize;
data.OpenCodePathButton.FontSize=newFontSize;
data.ArchiveProjectButton.FontSize=newFontSize;
data.UnarchiveProjectButton.FontSize=newFontSize;
data.OpenPISettingsPathButton.FontSize=newFontSize;