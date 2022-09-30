function []=processResize(src, event)

%% RESIZE THE COMPONENTS WITHIN THE PROCESS TAB.

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
        initFontSize=get(data.AddFcnButton,'FontSize'); % Get the initial font size
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
MapFigureRelPos=[0.5 0.07];
AddFcnButtonRelPos=[0.5 0.95];
RemoveFcnButtonRelPos=[0.87 0.95];
AddFcnTypeDropDownRelPos=[0.55 0.95];
MoveFcnButtonRelPos=[0.8 0.95];
PropagateChangesButtonRelPos=[0.5 0.01];
PropagateChangesCheckboxRelPos=[0.71 0.01];
RunSelectedFcnsButtonRelPos=[0.76 0.01];
CreateArgButtonRelPos=[0.01 0.95];
RemoveArgButtonRelPos=[0.12 0.95];
FcnNameLabelRelPos=[0.3 0.95];
FcnArgsUITreeRelPos=[0.3 0.65];
ArgNameInCodeLabelRelPos=[0.3 0.6];
ArgNameInCodeFieldRelPos=[0.3 0.55];
FcnDescriptionLabelRelPos=[0.3 0.45];
FcnDescriptionTextAreaRelPos=[0.3 0.25];
ArgDescriptionLabelRelPos=[0.3 0.21];
ArgDescriptionTextAreaRelPos=[0.3 0.01];
ShowInputVarsButtonRelPos=[0.64 0.9];
ShowOutputVarsButtonRelPos=[0.72 0.9];
AssignExistingArg2InputButtonRelPos=[0.23 0.9];
AssignExistingArg2OutputButtonRelPos=[0.23 0.85];
SplitsLabelRelPos=[0.01 0.45];
SplitsListboxRelPos=[0.01 0.25];
SplitsDescriptionLabelRelPos=[0.5 0.5];
SplitsTextAreaRelPos=[0.5 0.5];
FcnsArgsSearchFieldRelPos=[0.01 0.9];
SubVarLabelRelPos=[0.5 0.5];
SubVarUITreeRelPos=[0.5 0.5];
ConvertVarHardDynamicButtonRelPos=[0.3 0.49];
SpecifyTrialsUITreeRelPos=[0.01 0.01];
SpecifyTrialsLabelRelPos=[0.01 0.17];
RemoveSpecifyTrialsButtonRelPos=[0.22 0.1];
MarkImportFcnCheckboxRelPos=[0.38 0.95];
NewSpecifyTrialsButtonRelPos=[0.22 0.15];
NewSplitButtonRelPos=[0.225 0.45];
RemoveSplitButtonRelPos=[0.225 0.4];
SearchVarsFieldRelPos=[0.5 0.5];
VarsListboxRelPos=[0.01 0.50];
UnassignVarsButtonRelPos=[0.225 0.8];
EditSubvarsButtonRelPos=[0.215 0.7];
SplitsDescButtonRelPos=[0.22 0.3];
PlaceFcnButtonRelPos=[0.73 0.95];
SpecifyTrialsButtonRelPos=[0.01 0.11];
ConnectNodesButtonRelPos=[0.65 0.95];
DisconnectNodesButtonRelPos=[0.93 0.95];
FcnsRunOrderFieldRelPos=[0.56 0.95];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
MapFigureSize=[0.5 0.87];
AddFcnButtonSize=[0.05 compHeight];
RemoveFcnButtonSize=[0.05 compHeight];
AddFcnTypeDropDownSize=[0.2 compHeight];
MoveFcnButtonSize=[0.07 compHeight];
PropagateChangesButtonSize=[0.2 compHeight];
PropagateChangesCheckboxSize=[0.05 compHeight];
RunSelectedFcnsButtonSize=[0.2 compHeight];
CreateArgButtonSize=[0.06 compHeight];
RemoveArgButtonSize=[0.06 compHeight];
FcnNameLabelSize=[0.2 compHeight];
FcnArgsUITreeSize=[0.2 0.3];
ArgNameInCodeLabelSize=[0.2 compHeight];
ArgNameInCodeFieldSize=[0.2 compHeight];
FcnDescriptionLabelSize=[0.2 compHeight];
FcnDescriptionTextAreaSize=[0.2 0.2];
ArgDescriptionLabelSize=[0.2 compHeight];
ArgDescriptionTextAreaSize=[0.2 0.2];
ShowInputVarsButtonSize=[0.08 compHeight];
ShowOutputVarsButtonSize=[0.08 compHeight];
AssignExistingArg2InputButtonSize=[0.05 compHeight];
AssignExistingArg2OutputButtonSize=[0.05 compHeight];
SplitsLabelSize=[0.2 compHeight];
SplitsListboxSize=[0.2 0.2];
SplitsDescriptionLabelSize=[0.2 compHeight];
SplitsTextAreaSize=[0.2 0.2];
FcnsArgsSearchFieldSize=[0.2 compHeight];
SubVarLabelSize=[0.2 compHeight];
SubVarUITreeSize=[0.2 0.2];
ConvertVarHardDynamicButtonSize=[0.2 compHeight];
SpecifyTrialsUITreeSize=[0.2 0.2];
SpecifyTrialsLabelSize=[0.2 compHeight];
RemoveSpecifyTrialsButtonSize=[0.07 compHeight];
MarkImportFcnCheckboxSize=[0.1 compHeight];
NewSpecifyTrialsButtonSize=[0.07 compHeight];
NewSplitButtonSize=[0.06 compHeight];
RemoveSplitButtonSize=[0.06 compHeight];
SearchVarsFieldSize=[0.2 compHeight];
VarsListboxSize=[0.2 0.4];
UnassignVarsButtonSize=[0.06 compHeight];
EditSubvarsButtonSize=[0.08 compHeight];
SplitsDescButtonSize=[0.07 compHeight];
PlaceFcnButtonSize=[0.07 compHeight];
SpecifyTrialsButtonSize=[0.2 compHeight];
ConnectNodesButtonSize=[0.07 compHeight];
DisconnectNodesButtonSize=[0.07 compHeight];
FcnsRunOrderFieldSize=[0.05 compHeight];

%% Multiply the relative positions by the figure size to get the actual position.}
MapFigurePos=round([MapFigureRelPos.*figSize MapFigureSize.*figSize]);
AddFcnButtonPos=round([AddFcnButtonRelPos.*figSize AddFcnButtonSize(1)*figSize(1) AddFcnButtonSize(2)]);
RemoveFcnButtonPos=round([RemoveFcnButtonRelPos.*figSize RemoveFcnButtonSize(1)*figSize(1) RemoveFcnButtonSize(2)]);
AddFcnTypeDropDownPos=round([AddFcnTypeDropDownRelPos.*figSize AddFcnTypeDropDownSize(1)*figSize(1) AddFcnTypeDropDownSize(2)]);
MoveFcnButtonPos=round([MoveFcnButtonRelPos.*figSize MoveFcnButtonSize(1)*figSize(1) MoveFcnButtonSize(2)]);
PropagateChangesButtonPos=round([PropagateChangesButtonRelPos.*figSize PropagateChangesButtonSize(1)*figSize(1) PropagateChangesButtonSize(2)]);
PropagateChangesCheckboxPos=round([PropagateChangesCheckboxRelPos.*figSize PropagateChangesCheckboxSize(1)*figSize(1) PropagateChangesCheckboxSize(2)]);
RunSelectedFcnsButtonPos=round([RunSelectedFcnsButtonRelPos.*figSize RunSelectedFcnsButtonSize(1)*figSize(1) RunSelectedFcnsButtonSize(2)]);
CreateArgButtonPos=round([CreateArgButtonRelPos.*figSize CreateArgButtonSize(1)*figSize(1) CreateArgButtonSize(2)]);
RemoveArgButtonPos=round([RemoveArgButtonRelPos.*figSize RemoveArgButtonSize(1)*figSize(1) RemoveArgButtonSize(2)]);
FcnNameLabelPos=round([FcnNameLabelRelPos.*figSize FcnNameLabelSize(1)*figSize(1) FcnNameLabelSize(2)]);
FcnArgsUITreePos=round([FcnArgsUITreeRelPos.*figSize FcnArgsUITreeSize.*figSize]);
ArgNameInCodeLabelPos=round([ArgNameInCodeLabelRelPos.*figSize ArgNameInCodeLabelSize(1)*figSize(1) ArgNameInCodeLabelSize(2)]);
ArgNameInCodeFieldPos=round([ArgNameInCodeFieldRelPos.*figSize ArgNameInCodeFieldSize(1)*figSize(1) ArgNameInCodeFieldSize(2)]);
FcnDescriptionLabelPos=round([FcnDescriptionLabelRelPos.*figSize FcnDescriptionLabelSize(1)*figSize(1) FcnDescriptionLabelSize(2)]);
FcnDescriptionTextAreaPos=round([FcnDescriptionTextAreaRelPos.*figSize FcnDescriptionTextAreaSize.*figSize]);
ArgDescriptionLabelPos=round([ArgDescriptionLabelRelPos.*figSize ArgDescriptionLabelSize(1)*figSize(1) ArgDescriptionLabelSize(2)]);
ArgDescriptionTextAreaPos=round([ArgDescriptionTextAreaRelPos.*figSize ArgDescriptionTextAreaSize.*figSize]);
ShowInputVarsButtonPos=round([ShowInputVarsButtonRelPos.*figSize ShowInputVarsButtonSize(1)*figSize(1) ShowInputVarsButtonSize(2)]);
ShowOutputVarsButtonPos=round([ShowOutputVarsButtonRelPos.*figSize ShowOutputVarsButtonSize(1)*figSize(1) ShowOutputVarsButtonSize(2)]);
AssignExistingArg2InputButtonPos=round([AssignExistingArg2InputButtonRelPos.*figSize AssignExistingArg2InputButtonSize(1)*figSize(1) AssignExistingArg2InputButtonSize(2)]);
AssignExistingArg2OutputButtonPos=round([AssignExistingArg2OutputButtonRelPos.*figSize AssignExistingArg2OutputButtonSize(1)*figSize(1) AssignExistingArg2OutputButtonSize(2)]);
SplitsLabelPos=round([SplitsLabelRelPos.*figSize SplitsLabelSize(1)*figSize(1) SplitsLabelSize(2)]);
SplitsListboxPos=round([SplitsListboxRelPos.*figSize SplitsListboxSize.*figSize]);
SplitsDescriptionLabelPos=round([SplitsDescriptionLabelRelPos.*figSize SplitsDescriptionLabelSize(1)*figSize(1) SplitsDescriptionLabelSize(2)]);
SplitsTextAreaPos=round([SplitsTextAreaRelPos.*figSize SplitsTextAreaSize.*figSize]);
FcnsArgsSearchFieldPos=round([FcnsArgsSearchFieldRelPos.*figSize FcnsArgsSearchFieldSize(1)*figSize(1) FcnsArgsSearchFieldSize(2)]);
SubVarLabelPos=round([SubVarLabelRelPos.*figSize SubVarLabelSize(1)*figSize(1) SubVarLabelSize(2)]);
SubVarUITreePos=round([SubVarUITreeRelPos.*figSize SubVarUITreeSize.*figSize]);
ConvertVarHardDynamicButtonPos=round([ConvertVarHardDynamicButtonRelPos.*figSize ConvertVarHardDynamicButtonSize(1)*figSize(1) ConvertVarHardDynamicButtonSize(2)]);
SpecifyTrialsUITreePos=round([SpecifyTrialsUITreeRelPos.*figSize SpecifyTrialsUITreeSize.*figSize]);
SpecifyTrialsLabelPos=round([SpecifyTrialsLabelRelPos.*figSize SpecifyTrialsLabelSize(1)*figSize(1) SpecifyTrialsLabelSize(2)]);
RemoveSpecifyTrialsButtonPos=round([RemoveSpecifyTrialsButtonRelPos.*figSize RemoveSpecifyTrialsButtonSize(1)*figSize(1) RemoveSpecifyTrialsButtonSize(2)]);
MarkImportFcnCheckboxPos=round([MarkImportFcnCheckboxRelPos.*figSize MarkImportFcnCheckboxSize(1)*figSize(1) MarkImportFcnCheckboxSize(2)]);
NewSpecifyTrialsButtonPos=round([NewSpecifyTrialsButtonRelPos.*figSize NewSpecifyTrialsButtonSize(1)*figSize(1) NewSpecifyTrialsButtonSize(2)]);
NewSplitButtonPos=round([NewSplitButtonRelPos.*figSize NewSplitButtonSize(1)*figSize(1) NewSplitButtonSize(2)]);
RemoveSplitButtonPos=round([RemoveSplitButtonRelPos.*figSize RemoveSplitButtonSize(1)*figSize(1) RemoveSplitButtonSize(2)]);
SearchVarsFieldPos=round([SearchVarsFieldRelPos.*figSize SearchVarsFieldSize(1)*figSize(1) SearchVarsFieldSize(2)]);
VarsListboxPos=round([VarsListboxRelPos.*figSize VarsListboxSize.*figSize]);
UnassignVarsButtonPos=round([UnassignVarsButtonRelPos.*figSize UnassignVarsButtonSize(1)*figSize(1) UnassignVarsButtonSize(2)]);
EditSubvarsButtonPos=round([EditSubvarsButtonRelPos.*figSize EditSubvarsButtonSize(1)*figSize(1) EditSubvarsButtonSize(2)]);
SplitsDescButtonPos=round([SplitsDescButtonRelPos.*figSize SplitsDescButtonSize(1)*figSize(1) SplitsDescButtonSize(2)]);
PlaceFcnButtonPos=round([PlaceFcnButtonRelPos.*figSize PlaceFcnButtonSize(1)*figSize(1) PlaceFcnButtonSize(2)]);
SpecifyTrialsButtonPos=round([SpecifyTrialsButtonRelPos.*figSize SpecifyTrialsButtonSize(1)*figSize(1) SpecifyTrialsButtonSize(2)]);
ConnectNodesButtonPos=round([ConnectNodesButtonRelPos.*figSize ConnectNodesButtonSize(1)*figSize(1) ConnectNodesButtonSize(2)]);
DisconnectNodesButtonPos=round([DisconnectNodesButtonRelPos.*figSize DisconnectNodesButtonSize(1)*figSize(1) DisconnectNodesButtonSize(2)]);
FcnsRunOrderFieldPos=round([FcnsRunOrderFieldRelPos.*figSize FcnsRunOrderFieldSize(1)*figSize(1) FcnsRunOrderFieldSize(2)]);

data.MapFigure.Position=MapFigurePos;
data.AddFcnButton.Position=AddFcnButtonPos;
data.RemoveFcnButton.Position=RemoveFcnButtonPos;
% data.AddFcnTypeDropDown.Position=AddFcnTypeDropDownPos;
data.MoveFcnButton.Position=MoveFcnButtonPos;
data.PropagateChangesButton.Position=PropagateChangesButtonPos;
data.PropagateChangesCheckbox.Position=PropagateChangesCheckboxPos;
data.RunSelectedFcnsButton.Position=RunSelectedFcnsButtonPos;
data.CreateArgButton.Position=CreateArgButtonPos;
data.RemoveArgButton.Position=RemoveArgButtonPos;
data.FcnNameLabel.Position=FcnNameLabelPos;
data.FcnArgsUITree.Position=FcnArgsUITreePos;
data.ArgNameInCodeLabel.Position=ArgNameInCodeLabelPos;
data.ArgNameInCodeField.Position=ArgNameInCodeFieldPos;
data.FcnDescriptionLabel.Position=FcnDescriptionLabelPos;
data.FcnDescriptionTextArea.Position=FcnDescriptionTextAreaPos;
data.ArgDescriptionLabel.Position=ArgDescriptionLabelPos;
data.ArgDescriptionTextArea.Position=ArgDescriptionTextAreaPos;
% data.ShowInputVarsButton.Position=ShowInputVarsButtonPos;
% data.ShowOutputVarsButton.Position=ShowOutputVarsButtonPos;
data.AssignExistingArg2InputButton.Position=AssignExistingArg2InputButtonPos;
data.AssignExistingArg2OutputButton.Position=AssignExistingArg2OutputButtonPos;
data.SplitsLabel.Position=SplitsLabelPos;
data.SplitsListbox.Position=SplitsListboxPos;
% data.SplitsDescriptionLabel.Position=SplitsDescriptionLabelPos;
% data.SplitsTextArea.Position=SplitsTextAreaPos;
data.FcnsArgsSearchField.Position=FcnsArgsSearchFieldPos;
% data.SubVarLabel.Position=SubVarLabelPos;
% data.SubVarUITree.Position=SubVarUITreePos;
data.ConvertVarHardDynamicButton.Position=ConvertVarHardDynamicButtonPos;
data.SpecifyTrialsUITree.Position=SpecifyTrialsUITreePos;
data.SpecifyTrialsLabel.Position=SpecifyTrialsLabelPos;
data.RemoveSpecifyTrialsButton.Position=RemoveSpecifyTrialsButtonPos;
data.MarkImportFcnCheckbox.Position=MarkImportFcnCheckboxPos;
data.NewSpecifyTrialsButton.Position=NewSpecifyTrialsButtonPos;
data.NewSplitButton.Position=NewSplitButtonPos;
data.RemoveSplitButton.Position=RemoveSplitButtonPos;
% data.SearchVarsField.Position=SearchVarsFieldPos;
data.VarsListbox.Position=VarsListboxPos;
data.UnassignVarsButton.Position=UnassignVarsButtonPos;
data.EditSubvarsButton.Position=EditSubvarsButtonPos;
data.SplitsDescButton.Position=SplitsDescButtonPos;
data.PlaceFcnButton.Position=PlaceFcnButtonPos;
data.SpecifyTrialsButton.Position=SpecifyTrialsButtonPos;
data.ConnectNodesButton.Position=ConnectNodesButtonPos;
data.DisconnectNodesButton.Position=DisconnectNodesButtonPos;
data.FcnsRunOrderField.Position=FcnsRunOrderFieldPos;

data.MapFigure.FontSize=newFontSize;
data.AddFcnButton.FontSize=newFontSize;
data.RemoveFcnButton.FontSize=newFontSize;
% data.AddFcnTypeDropDown.FontSize=newFontSize;
data.MoveFcnButton.FontSize=newFontSize;
data.PropagateChangesButton.FontSize=newFontSize;
data.PropagateChangesCheckbox.FontSize=newFontSize;
data.RunSelectedFcnsButton.FontSize=newFontSize;
data.CreateArgButton.FontSize=newFontSize;
data.RemoveArgButton.FontSize=newFontSize;
data.FcnNameLabel.FontSize=newFontSize;
% data.FcnArgsUITree.FontSize=newFontSize; % CAN TOGGLE THIS FOR DIFFERENT BEHAVIOR
data.ArgNameInCodeLabel.FontSize=newFontSize;
data.ArgNameInCodeField.FontSize=newFontSize;
data.FcnDescriptionLabel.FontSize=newFontSize;
data.FcnDescriptionTextArea.FontSize=newFontSize;
data.ArgDescriptionLabel.FontSize=newFontSize;
data.ArgDescriptionTextArea.FontSize=newFontSize;
% data.ShowInputVarsButton.FontSize=newFontSize;
% data.ShowOutputVarsButton.FontSize=newFontSize;
data.AssignExistingArg2InputButton.FontSize=newFontSize;
data.AssignExistingArg2OutputButton.FontSize=newFontSize;
data.SplitsLabel.FontSize=newFontSize;
data.SplitsListbox.FontSize=newFontSize;
% data.SplitsDescriptionLabel.FontSize=newFontSize;
% data.SplitsTextArea.FontSize=newFontSize;
data.FcnsArgsSearchField.FontSize=newFontSize;
% data.SubVarLabel.FontSize=newFontSize;
% data.SubVarUITree.FontSize=newFontSize;
data.ConvertVarHardDynamicButton.FontSize=newFontSize;
data.SpecifyTrialsUITree.FontSize=newFontSize;
data.SpecifyTrialsLabel.FontSize=newFontSize;
data.RemoveSpecifyTrialsButton.FontSize=newFontSize;
data.MarkImportFcnCheckbox.FontSize=newFontSize;
data.NewSpecifyTrialsButton.FontSize=newFontSize;
data.NewSplitButton.FontSize=newFontSize;
data.RemoveSplitButton.FontSize=newFontSize;
% data.SearchVarsField.FontSize=newFontSize;
% data.VarsListbox.FontSize=newFontSize; % CAN TOGGLE THIS FOR DIFFERENT BEHAVIOR
data.UnassignVarsButton.FontSize=newFontSize;
data.EditSubvarsButton.FontSize=newFontSize;
data.SplitsDescButton.FontSize=newFontSize;
data.PlaceFcnButton.FontSize=newFontSize;
data.SpecifyTrialsButton.FontSize=newFontSize;
data.ConnectNodesButton.FontSize=newFontSize;
data.DisconnectNodesButton.FontSize=newFontSize;
data.FcnsRunOrderField.FontSize=newFontSize;