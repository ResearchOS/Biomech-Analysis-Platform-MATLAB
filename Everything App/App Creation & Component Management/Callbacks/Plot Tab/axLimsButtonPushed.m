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

if ~isfield(Plotting.Plots.(plotName),'ExTrial')
    disp('Set example trial first!');
    return;
end

axLetter=handles.Plot.currCompUITree.SelectedNodes.Text;

axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;

if isfield(Plotting.Plots.(plotName).Axes.(axLetter),'AxLims')
    axLims=Plotting.Plots.(plotName).Axes.(axLetter).AxLims;
end

if isMovie==1
    isHC=1;
else
    isHC=0;
end

fieldnames={'VariableNames','SubvarNames','VariableValue','Level','IsHardCoded','RelativeView'};
values={{},{},'[0 1]','T',isHC,1};

for dim='XYZ'
    for i=1:length(fieldnames)
        if ~exist('axLims','var') || ~isfield(axLims,dim) || ~isfield(axLims.(dim),fieldnames{i})
            axLims.(dim).(fieldnames{i})=values{i};
        end
    end
end

isHardCoded=axLims.X.IsHardCoded;
level=axLims.X.Level;
value=axLims.X.VariableValue;

%% Open figure to select the data for the axes limits.
Q=uifigure('Name',['Set Axes ' axLetter ' Limits'],'DeleteFcn',@(Q,event) axesLimDeleteFcn(Q,fig));
Qhandles.dimDropDown=uidropdown(Q,'Position',[500 200 100 50],'Items',{'X','Y','Z'},'Value','X','Editable','off','ValueChangedFcn',@(Q,event) dimDropDownValueChanged(Q));
Qhandles.varsUITree=uitree(Q,'Position',[10 10 200 400],'Visible',~isHardCoded,'SelectionChangedFcn',@(Q,event) varsUITreeSelectionChanged(Q));
Qhandles.selVarsUITree=uitree(Q,'Position',[270 10 200 300],'SelectionChangedFcn',@(Q,event) selVarsUITreeValueChanged(Q),'Visible',~isHardCoded);
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignVarButtonPushedAxesLims(Q),'Visible',~isHardCoded);
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignVarButtonPushedAxesLims(Q),'Visible',~isHardCoded);
Qhandles.isHardCodedCheckbox=uicheckbox(Q,'Position',[10 460 150 50],'Value',isHardCoded,'Text','Is Hard Coded?','ValueChangedFcn',@(Q,event) hardCodedCheckboxValueChanged(Q));
% Qhandles.nameInCodeEditField=uieditfield(Q,'text','Position',[270 310 200 50],'ValueChangedFcn',@(Q,event) nameInCodeEditFieldValueChanged(Q),'Visible',~isHardCoded);
Qhandles.subVarEditField=uieditfield(Q,'text','Position',[270 370 200 50],'Visible',~isHardCoded,'ValueChangedFcn',@(Q,event) subVarEditFieldValueChanged(Q));
Qhandles.hardCodedTextArea=uitextarea(Q,'Position',[10 250 450 200],'Visible',isHardCoded,'ValueChangedFcn',@(Q,event) hardCodedTextAreaValueChanged(Q),'Value',value);
Qhandles.levelDropDown=uidropdown(Q,'Items',{'P','C','S','SC','T'},'Position',[270 420 200 50],'Value',level,'ValueChangedFcn',@(Q,event) levelDropDownValueChanged(Q),'Visible',~isHardCoded);
Qhandles.searchEditField=uieditfield(Q,'text','Value','Search','Visible',~isHardCoded,'Position',[10 420 200 50],'ValueChangingFcn',@(Q,event) searchAxLimsVars(Q,event));
Qhandles.relativeViewCheckbox=uicheckbox(Q,'Text','Relative View','Position',[210 460 150 50],'Visible',(isMovie && isHardCoded),'Value',axLims.X.RelativeView,'ValueChangedFcn',@(Q,event) relativeViewCheckboxValueChanged(Q));

setappdata(Q,'axHandle',axHandle);
setappdata(Q,'handles',Qhandles);
setappdata(Q,'axLims',axLims);
setappdata(Q,'plotName',plotName);
setappdata(Q,'axLetter',axLetter);
VariableNamesList=getappdata(fig,'VariableNamesList');
setappdata(Q,'VariableNamesList',VariableNamesList);
setappdata(Q,'isMovie',isMovie);

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));
makeAxLimsVarNodes(Q,sortIdx,VariableNamesList);

% Fill in the selected variables UI tree and the subvariables edit field.
makeAxLimsSelVarNodes(Q);