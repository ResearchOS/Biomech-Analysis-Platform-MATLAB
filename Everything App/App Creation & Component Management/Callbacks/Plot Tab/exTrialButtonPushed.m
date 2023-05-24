function []=exTrialButtonPushed(src,event)

%% PURPOSE: SET WHICH EXAMPLE TRIAL IS BEING PLOTTED IN THE APP.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

assignin('base','gui',fig);

slash=filesep;

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

if ~isfield(Plotting.Plots.(plotName),'SpecifyTrials')
    disp('Do the specify trials first!');
    return;
end

specTrials=Plotting.Plots.(plotName).SpecifyTrials;

codePath=getappdata(fig,'codePath');

specTrialsPath=[codePath 'SpecifyTrials'];

oldPath=cd(specTrialsPath);

inclStruct=feval(specTrials);
load(getappdata(fig,'logsheetPathMAT'),'logVar');

allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);

subNames=fieldnames(allTrialNames);

[sub,val]=listdlg('ListString',subNames,'PromptString','Select a Subject','SelectionMode','single');
if val==0
    return;
end
subName=subNames{sub};

trialNames=fieldnames(allTrialNames.(subName));

[trial,val]=listdlg('ListString',trialNames,'PromptString','Select a Trial','SelectionMode','single');
trialName=trialNames{trial};
if val==0
    return;
end

PlotExTrial.Subject=subName;
PlotExTrial.Trial=trialName;
PlotExTrial.Condition=[];

% Get the condition number
allTrialNames=getTrialNames(inclStruct,logVar,fig,1,[]);
% subNameOrig=subName;
for condNum=1:length(allTrialNames.Condition)
    subNames=fieldnames(allTrialNames.Condition(condNum));
    if ~ismember(subName,subNames)
        continue; % Go on to the next trial.
    end
    currTrials=fieldnames(allTrialNames.Condition(condNum).(subName));
    if ismember(trialName,currTrials)
        PlotExTrial.Condition=condNum;
        break;
    end
end

Plotting.Plots.(plotName).ExTrial=PlotExTrial;

cd(oldPath);

setappdata(fig,'Plotting',Plotting);

if Plotting.Plots.(plotName).Movie.IsMovie==1
    err=0;
    projectName=getappdata(fig,'projectName');
    if ~isempty(Plotting.Plots.(plotName).Movie.startFrameVar)
        varName=Plotting.Plots.(plotName).Movie.startFrameVar;
        try
            a=load([codePath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'],varName);
            a=a.(varName);
            if ~isscalar(a)
                error('Start frame must be scalar!');
            end
            handles.Plot.startFrameEditField.Value=a;
            startFrameEditFieldValueChanged(fig,1);
            err=0;
        catch
            err=1;
            disp('Error updating the start frame for the new trial!');
        end
        
    end

    if ~isempty(Plotting.Plots.(plotName).Movie.endFrameVar)
        varName=Plotting.Plots.(plotName).Movie.endFrameVar;
        try
            a=load([codePath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'],varName);
            a=a.(varName);
            if ~isscalar(a)
                error('End frame must be scalar!');
            end
            handles.Plot.endFrameEditField.Value=a;
            endFrameEditFieldValueChanged(fig,1);
            err=0;
        catch
            err=1;
            disp('Error updating the end frame for the new trial!');
        end
    end    

    if err==0
        handles.Plot.currFrameEditField.Value=handles.Plot.startFrameEditField.Value;
        currFrameEditFieldValueChanged(fig);
    end
end

handles.Plot.exTrialLabel.Text=[subName ' ' trialName];

% If this is a movie, set the center data variable by just calling the axLims GUI
axesNodes=handles.Plot.currCompUITree.Children.Children;
for i=1:length(axesNodes)
    selNode=axesNodes(i);
    handles.Plot.currCompUITree.SelectedNodes=selNode;
    axLimsButtonPushed(fig);
    Q=findall(0,'Name',['Set Axes ' selNode.Text ' Limits']);
    close(Q);
end

axesNode=handles.Plot.currCompUITree.Children;
refreshAllSubComps(fig,[],axesNode);