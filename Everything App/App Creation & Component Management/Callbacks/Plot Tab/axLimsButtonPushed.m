function []=axLimsButtonPushed(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO SET THE AXIS LIMITS FOR THE CURRENT PLOT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% CAN EITHER BE HARD-CODED, OR BASED ON VARIABLES.
% IF BASED ON VARIABLES, CAN BE BASED ON TRIAL, SUBJECT, OR PROJECT LEVEL EXTREMA SO THAT ALL PLOTS HAVE THE SAME AXES LIMITS
if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    return;
end

axLetter=handles.Plot.currCompUITree.SelectedNodes.Text;

axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;

if isfield(Plotting.Plots.(plotName).Axes.(axLetter),'AxLims')
    axLims=Plotting.Plots.(plotName).Axes.(axLetter).AxLims;
else
    axLims.X.VariableNames={};
    axLims.X.SubvarNames={};
    axLims.X.VariableValue='[0 1]';
    axLims.X.IsHardCoded=0;
    axLims.X.Level='T';

    axLims.Y.VariableNames={};
    axLims.Y.SubvarNames={};
    axLims.Y.VariableValue='[0 1]';
    axLims.Y.IsHardCoded=0;
    axLims.Y.Level='T';

    axLims.Z.VariableNames={};
    axLims.Z.SubvarNames={};
    axLims.Z.VariableValue='[0 1]';
    axLims.Z.IsHardCoded=0;
    axLims.Z.Level='T';
end

isHardCoded=axLims.X.IsHardCoded;
level=axLims.X.Level;
value=axLims.X.VariableValue;

%% Open figure to select the data for the axes limits.
Q=uifigure('Name',['Set Axes ' axLetter ' Limits'],'DeleteFcn',@(Q,fig) axesLimDeleteFcn(Q,fig));
Qhandles.dimDropDown=uidropdown(Q,'Position',[500 200 100 50],'Items',{'X','Y','Z'},'Value','X','Editable','off','ValueChangedFcn',@(Q,event) dimDropDownValueChanged(Q));
Qhandles.varsUITree=uitree(Q,'Position',[10 10 200 400],'Visible',~isHardCoded,'SelectionChangedFcn',@(Q,event) varsUITreeSelectionChanged(Q));
Qhandles.selVarsUITree=uitree(Q,'Position',[270 10 200 300],'SelectionChangedFcn',@(Q,event) selVarsUITreeValueChanged(Q),'Visible',~isHardCoded);
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignVarButtonPushedAxesLims(Q),'Visible',~isHardCoded);
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignVarButtonPushedAxesLims(Q),'Visible',~isHardCoded);
Qhandles.isHardCodedCheckbox=uicheckbox(Q,'Position',[10 460 150 50],'Value',isHardCoded,'Text','Is Hard Coded?','ValueChangedFcn',@(Q,event) hardCodedCheckboxValueChanged(Q));
% Qhandles.nameInCodeEditField=uieditfield(Q,'text','Position',[270 310 200 50],'ValueChangedFcn',@(Q,event) nameInCodeEditFieldValueChanged(Q),'Visible',~isHardCoded);
Qhandles.subVarEditField=uieditfield(Q,'text','Position',[270 370 200 50],'Visible',~isHardCoded,'ValueChangedFcn',@(Q,event) subVarEditFieldValueChanged(Q));
Qhandles.hardCodedTextArea=uitextarea(Q,'Position',[10 250 450 200],'Visible',isHardCoded,'ValueChangedFcn',@(Q,event) hardCodedTextAreaValueChanged(Q),'Value',value);
Qhandles.levelDropDown=uidropdown(Q,'Items',{'P','C','S','SC','T'},'Position',[270 420 200 50],'Value',level,'ValueChangedFcn',@(Q,event) levelDropDownValueChanged(Q));
Qhandles.searchEditField=uieditfield(Q,'text','Value','Search','Visible',~isHardCoded,'Position',[10 420 200 50],'ValueChangingFcn',@(Q,event) searchAxLimsVars(Q,event));

setappdata(Q,'axHandle',axHandle);
setappdata(Q,'handles',Qhandles);
setappdata(Q,'axLims',axLims);
VariableNamesList=getappdata(fig,'VariableNamesList');
setappdata(Q,'VariableNamesList',VariableNamesList);

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));
makeAxLimsVarNodes(Q,sortIdx,VariableNamesList);

% Fill in the selected variables UI tree and the subvariables edit field.
makeAxLimsSelVarNodes(Q);