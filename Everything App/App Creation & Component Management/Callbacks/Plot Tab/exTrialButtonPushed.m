function []=exTrialButtonPushed(src,event)

%% PURPOSE: SET WHICH EXAMPLE TRIAL IS BEING PLOTTED IN THE APP.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% slash=filesep;

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

specTrials=Plotting.Plots.(plotName).SpecifyTrials;

codePath=getappdata(fig,'codePath');

specTrialsPath=[codePath 'SpecifyTrials'];

oldPath=cd(specTrialsPath);

inclStruct=feval(specTrials);
load(getappdata(fig,'logsheetPathMAT'),'logVar');

allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);

subNames=fieldnames(allTrialNames);

sub=listdlg('ListString',subNames,'PromptString','Select a Subject','SelectionMode','single');
if isempty(sub)
    return;
end
subName=subNames{sub};

trialNames=fieldnames(allTrialNames.(subName));

trial=listdlg('ListString',trialNames,'PromptString','Select a Trial','SelectionMode','single');
trialName=trialNames{trial};
if isempty(trial)
    return;
end

PlotExTrial.Subject=subName;
PlotExTrial.Trial=trialName;

Plotting.Plots.(plotName).ExTrial=PlotExTrial;

setappdata(fig,'Plotting',Plotting);

cd(oldPath);