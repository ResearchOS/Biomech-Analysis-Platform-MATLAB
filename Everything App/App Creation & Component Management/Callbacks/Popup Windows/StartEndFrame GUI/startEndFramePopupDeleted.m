function []=startEndFramePopupDeleted(src,event)

%% PURPOSE:
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

idxType=getappdata(fig,'idxType');

selNode=Qhandles.varsListbox.SelectedNodes;

if isempty(selNode)
    return;
end

if isequal(selNode.Parent,Qhandles.varsListbox)
    disp('Select the split name, not the variable itself!');
    return;
end

currSplit=selNode.Text;
spaceIdx=strfind(currSplit,' ');
splitCode=currSplit(spaceIdx+2:end-1);

currVar=selNode.Parent.Text;
pgui=findall(0,'Name','pgui');
VariableNamesList=getappdata(pgui,'VariableNamesList');
varIdx=ismember(VariableNamesList.GUINames,currVar);
saveName=VariableNamesList.SaveNames{varIdx};
% currVar=strrep(currVar,' ','_');

varName=[saveName '_' splitCode];

%% Load the variable
try    
    handles=getappdata(pgui,'handles');
    Plotting=getappdata(pgui,'Plotting');
    plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;
    exTrial=Plotting.Plots.(plotName).ExTrial;
    trialName=exTrial.Trial;
    subName=exTrial.Subject;
    projectName=getappdata(pgui,'projectName');
    codePath=getappdata(pgui,'codePath');
    slash=filesep;
    a=load([codePath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'],varName);
    a=a.(varName);
catch
    disp('Error with loading the data!');
    return;
end

%% Check it for being a scalar
if ~isscalar(a)
    disp('Must be a scalar!');
    return;
end

%% Assign it to the plot.
switch idxType
    case 'startFrame'
        Plotting.Plots.(plotName).Movie.startFrame=a;
        Plotting.Plots.(plotName).Movie.startFrameVar=varName;
        handles.Plot.startFrameEditField.Value=Plotting.Plots.(plotName).Movie.startFrame;
        if Plotting.Plots.(plotName).Movie.currFrame<Plotting.Plots.(plotName).Movie.startFrame
            Plotting.Plots.(plotName).Movie.currFrame=Plotting.Plots.(plotName).Movie.startFrame;    
            currFrameEditFieldValueChanged(pgui);
        end
    case 'endFrame'
        Plotting.Plots.(plotName).Movie.endFrame=a;
        Plotting.Plots.(plotName).Movie.endFrameVar=varName;
        handles.Plot.endFrameEditField.Value=Plotting.Plots.(plotName).Movie.endFrame;
        if Plotting.Plots.(plotName).Movie.currFrame>Plotting.Plots.(plotName).Movie.endFrame
            Plotting.Plots.(plotName).Movie.currFrame=Plotting.Plots.(plotName).Movie.endFrame;
            currFrameEditFieldValueChanged(pgui);
        end
end

setappdata(pgui,'Plotting',Plotting);
handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;