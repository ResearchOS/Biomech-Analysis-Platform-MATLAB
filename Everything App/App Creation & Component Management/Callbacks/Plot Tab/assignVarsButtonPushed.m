function []=assignVarsButtonPushed(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO MODIFY THE VARIABLES ASSOCIATED WITH THE CURRENTLY SELECTED GRAPHICS OBJECT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

compNames=fieldnames(Plotting.Plots.(plotName));

currComp=handles.Plot.currCompUITree.SelectedNodes;
if isempty(currComp)
    disp('Select a component!');
    return;
end
letter=currComp.Text;

if ismember(letter,compNames)
    disp('Must select the letter for the component, not the component name!');
    return;
end

compName=currComp.Parent.Text;

if isequal(compName,'Axes')
    return;
end

structComp=Plotting.Plots.(plotName).(compName).(letter).Variables;

if ~isfield(structComp,'Names') % Initialize
    structComp.Names={};
    structComp.NamesInCode={};
    structComp.IsHardCoded=0;
    structComp.HardCodedValue='';
end

% Backwards compatibility
if any(structComp.IsHardCoded==0)
    structComp.IsHardCoded=0;
end

%% Create popup window to assign variables to component.
VariableNamesList=getappdata(fig,'VariableNamesList');
[~,idx]=sort(upper(VariableNamesList.GUINames));
Q=uifigure('Visible','on','Name','Assign Variables','DeleteFcn',@(Q,event) assignVarsDeleteFcn(Q));
Qhandles.varsListbox=uitree(Q,'Position',[10 10 200 450],'Visible',~structComp.IsHardCoded);
Qhandles.selVarsListbox=uitree(Q,'Position',[270 10 200 300],'SelectionChangedFcn',@(Q,event) selVarsListboxValueChanged(Q),'Visible',~structComp.IsHardCoded);
Qhandles.varNameInCodeEditField=uieditfield(Q,'Position',[270 310 200 50],'ValueChangedFcn',@(Q,event) varNameInCodeEditFieldValueChanged(Q),'Visible',~structComp.IsHardCoded);
Qhandles.isHardCoded=uicheckbox(Q,'Position',[10 460 150 50],'Value',structComp.IsHardCoded,'Text','Is Hard Coded?','ValueChangedFcn',@(Q,event) isHardCodedCheckboxValueChanged(Q));
Qhandles.hardCodedTextArea=uitextarea(Q,'Position',[10 250 450 200],'Visible',Qhandles.isHardCoded.Value,'ValueChangedFcn',@(Q,event) hardCodedValueChanged(Q),'Visible',structComp.IsHardCoded);
Qhandles.assignVarButton=uibutton(Q,'Position',[210 150 50 50],'Text','->','ButtonPushedFcn',@(Q,event) assignVarButtonPushed(Q),'Visible',~structComp.IsHardCoded);
Qhandles.unassignVarButton=uibutton(Q,'Position',[210 100 50 50],'Text','<-','ButtonPushedFcn',@(Q,event) unassignVarButtonPushed(Q),'Visible',~structComp.IsHardCoded);
Qhandles.subvarsTextArea=uitextarea(Q,'Position',[270 370 200 50],'Visible',~Qhandles.isHardCoded.Value,'ValueChangedFcn',@(Q,event) subvarsTextAreaValueChanged(Q),'Visible',~structComp.IsHardCoded);

setappdata(Q,'handles',Qhandles);
setappdata(Q,'plotName',plotName);
setappdata(Q,'compName',compName);
setappdata(Q,'letter',letter);
setappdata(Q,'structComp',structComp);
makeVarNodesPlotArgsPopup(Q,idx,VariableNamesList,structComp);