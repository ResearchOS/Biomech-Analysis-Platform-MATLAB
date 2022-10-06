function []=statsResize(src,event)

%% PURPOSE: RESIZE THE COMPONENTS IN THE STATS TAB

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
newFontSize=round(fontSizeRelToHeight*ancSize(2)); % Multiply relative font size by the figures height
if newFontSize>20
    newFontSize=20; % Cap the font size (and therefore the text box/button sizes too)
end

%% Positions specified as relative to tab width & height
% All positions here are specified as relative positions
VarsUITreeRelPos=[0.01 0.59];
CreateTableButtonRelPos=[0.1 0.5];
RemoveTableButtonRelPos=[0.01 0.5];
TablesUITreeRelPos=[0.01 0.1];
SpecifyTrialsButtonRelPos=[0.01 0.01];
AddRepsVarButtonRelPos=[0.22 0.9];
AddVarsButtonRelPos=[0.22 0.85];
RemoveVarsButtonRelPos=[0.22 0.8];
VarUpButtonRelPos=[0.23 0.7];
VarDownButtonRelPos=[0.23 0.6];
AsssignedVarsUITreeRelPos=[0.3 0.49];
AssignFcnButtonRelPos=[0.51 0.8];
UnassignFcnButtonRelPos=[0.51 0.75];
CreateFcnButtonRelPos=[0.62 0.95];
RemoveFcnButtonRelPos=[0.72 0.95];
FcnsUITreeRelPos=[0.6 0.5];
RunButtonRelPos=[0.85 0.7];
AssignVarsButtonRelPos=[0.51 0.85];
VarsDescLabelRelPos=[0.3 0.45];
VarsDescTextAreaRelPos=[0.3 0.25];
TableDescLabelRelPos=[0.3 0.2];
TableDescTextAreaRelPos=[0.3 0.01];
MatrixButtonRelPos=[0.55 0.25];
MatrixRepsUITreeRelPos=[0.7 0.01];

%% Component width specified relative to tab width, height is in absolute units (constant).
% All component dimensions here are specified as absolute sizes (pixels)
compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
VarsUITreeSize=[0.2 0.4];
CreateTableButtonSize=[0.06 compHeight];
RemoveTableButtonSize=[0.06 compHeight];
TablesUITreeSize=[0.2 0.4];
SpecifyTrialsButtonSize=[0.2 compHeight];
AddRepsVarButtonSize=[0.06 compHeight];
AddVarsButtonSize=[0.06 compHeight];
RemoveVarsButtonSize=[0.06 compHeight];
VarUpButtonSize=[0.04 2*compHeight];
VarDownButtonSize=[0.04 2*compHeight];
AsssignedVarsUITreeSize=[0.2 0.5];
AssignFcnButtonSize=[0.06 compHeight];
UnassignFcnButtonSize=[0.06 compHeight];
CreateFcnButtonSize=[0.06 compHeight];
RemoveFcnButtonSize=[0.06 compHeight];
FcnsUITreeSize=[0.2 0.45];
RunButtonSize=[0.1 2*compHeight];
AssignVarsButtonSize=[0.06 2*compHeight];
VarsDescLabelSize=[0.2 compHeight];
VarsDescTextAreaSize=[0.2 0.2];
TableDescLabelSize=[0.2 compHeight];
TableDescTextAreaSize=[0.2 0.19];
MatrixButtonSize=[0.1 2*compHeight];
MatrixRepsUITreeSize=[0.2 0.4];

%% Multiply the relative positions by the figure size to get the actual position.}
VarsUITreePos=round([VarsUITreeRelPos.*figSize VarsUITreeSize.*figSize]);
CreateTableButtonPos=round([CreateTableButtonRelPos.*figSize CreateTableButtonSize(1)*figSize(1) CreateTableButtonSize(2)]);
RemoveTableButtonPos=round([RemoveTableButtonRelPos.*figSize RemoveTableButtonSize(1)*figSize(1) RemoveTableButtonSize(2)]);
TablesUITreePos=round([TablesUITreeRelPos.*figSize TablesUITreeSize.*figSize]);
SpecifyTrialsButtonPos=round([SpecifyTrialsButtonRelPos.*figSize SpecifyTrialsButtonSize(1)*figSize(1) SpecifyTrialsButtonSize(2)]);
AddRepsVarButtonPos=round([AddRepsVarButtonRelPos.*figSize AddRepsVarButtonSize(1)*figSize(1) AddRepsVarButtonSize(2)]);
AddVarsButtonPos=round([AddVarsButtonRelPos.*figSize AddVarsButtonSize(1)*figSize(1) AddVarsButtonSize(2)]);
RemoveVarsButtonPos=round([RemoveVarsButtonRelPos.*figSize RemoveVarsButtonSize(1)*figSize(1) RemoveVarsButtonSize(2)]);
VarUpButtonPos=round([VarUpButtonRelPos.*figSize VarUpButtonSize(1)*figSize(1) VarUpButtonSize(2)]);
VarDownButtonPos=round([VarDownButtonRelPos.*figSize VarDownButtonSize(1)*figSize(1) VarDownButtonSize(2)]);
AsssignedVarsUITreePos=round([AsssignedVarsUITreeRelPos.*figSize AsssignedVarsUITreeSize.*figSize]);
AssignFcnButtonPos=round([AssignFcnButtonRelPos.*figSize AssignFcnButtonSize(1)*figSize(1) AssignFcnButtonSize(2)]);
UnassignFcnButtonPos=round([UnassignFcnButtonRelPos.*figSize UnassignFcnButtonSize(1)*figSize(1) UnassignFcnButtonSize(2)]);
CreateFcnButtonPos=round([CreateFcnButtonRelPos.*figSize CreateFcnButtonSize(1)*figSize(1) CreateFcnButtonSize(2)]);
RemoveFcnButtonPos=round([RemoveFcnButtonRelPos.*figSize RemoveFcnButtonSize(1)*figSize(1) RemoveFcnButtonSize(2)]);
FcnsUITreePos=round([FcnsUITreeRelPos.*figSize FcnsUITreeSize.*figSize]);
RunButtonPos=round([RunButtonRelPos.*figSize RunButtonSize(1)*figSize(1) RunButtonSize(2)]);
AssignVarsButtonPos=round([AssignVarsButtonRelPos.*figSize AssignVarsButtonSize(1)*figSize(1) AssignVarsButtonSize(2)]);
VarsDescLabelPos=round([VarsDescLabelRelPos.*figSize VarsDescLabelSize(1)*figSize(1) VarsDescLabelSize(2)]);
VarsDescTextAreaPos=round([VarsDescTextAreaRelPos.*figSize VarsDescTextAreaSize.*figSize]);
TableDescLabelPos=round([TableDescLabelRelPos.*figSize TableDescLabelSize(1)*figSize(1) TableDescLabelSize(2)]);
TableDescTextAreaPos=round([TableDescTextAreaRelPos.*figSize TableDescTextAreaSize.*figSize]);
MatrixButtonPos=round([MatrixButtonRelPos.*figSize MatrixButtonSize(1)*figSize(1) MatrixButtonSize(2)]);
MatrixRepsUITreePos=round([MatrixRepsUITreeRelPos.*figSize MatrixRepsUITreeSize.*figSize]);
data.VarsUITree.Position=VarsUITreePos;
data.CreateTableButton.Position=CreateTableButtonPos;
data.RemoveTableButton.Position=RemoveTableButtonPos;
data.TablesUITree.Position=TablesUITreePos;
data.SpecifyTrialsButton.Position=SpecifyTrialsButtonPos;
data.AddRepsVarButton.Position=AddRepsVarButtonPos;
data.AddVarsButton.Position=AddVarsButtonPos;
data.RemoveVarsButton.Position=RemoveVarsButtonPos;
data.VarUpButton.Position=VarUpButtonPos;
data.VarDownButton.Position=VarDownButtonPos;
data.AsssignedVarsUITree.Position=AsssignedVarsUITreePos;
data.AssignFcnButton.Position=AssignFcnButtonPos;
data.UnassignFcnButton.Position=UnassignFcnButtonPos;
data.CreateFcnButton.Position=CreateFcnButtonPos;
data.RemoveFcnButton.Position=RemoveFcnButtonPos;
data.FcnsUITree.Position=FcnsUITreePos;
data.RunButton.Position=RunButtonPos;
data.AssignVarsButton.Position=AssignVarsButtonPos;
data.VarsDescLabel.Position=VarsDescLabelPos;
data.VarsDescTextArea.Position=VarsDescTextAreaPos;
data.TableDescLabel.Position=TableDescLabelPos;
data.TableDescTextArea.Position=TableDescTextAreaPos;
data.MatrixButton.Position=MatrixButtonPos;
data.MatrixRepsUITree.Position=MatrixRepsUITreePos;
data.VarsUITree.FontSize=newFontSize;
data.CreateTableButton.FontSize=newFontSize;
data.RemoveTableButton.FontSize=newFontSize;
data.TablesUITree.FontSize=newFontSize;
data.SpecifyTrialsButton.FontSize=newFontSize;
data.AddRepsVarButton.FontSize=newFontSize;
data.AddVarsButton.FontSize=newFontSize;
data.RemoveVarsButton.FontSize=newFontSize;
data.VarUpButton.FontSize=newFontSize;
data.VarDownButton.FontSize=newFontSize;
data.AsssignedVarsUITree.FontSize=newFontSize;
data.AssignFcnButton.FontSize=newFontSize;
data.UnassignFcnButton.FontSize=newFontSize;
data.CreateFcnButton.FontSize=newFontSize;
data.RemoveFcnButton.FontSize=newFontSize;
data.FcnsUITree.FontSize=newFontSize;
data.RunButton.FontSize=newFontSize;
data.AssignVarsButton.FontSize=newFontSize;
data.VarsDescLabel.FontSize=newFontSize;
data.VarsDescTextArea.FontSize=newFontSize;
data.TableDescLabel.FontSize=newFontSize;
data.TableDescTextArea.FontSize=newFontSize;
data.MatrixButton.FontSize=newFontSize;
data.MatrixRepsUITree.FontSize=newFontSize;