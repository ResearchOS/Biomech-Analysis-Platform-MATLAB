function []=runPlotButtonPushed(src,event)

%% PURPOSE: RUN THE PLOTS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.plotFcnUITree.SelectedNodes;

if isempty(selNode)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=selNode.Text;

specTrials=Plotting.Plots.(plotName).SpecifyTrials;
isMovie=Plotting.Plots.(plotName).Movie.IsMovie;

oldPath=cd([getappdata(fig,'codePath') 'SpecifyTrials']);
inclStruct=feval(specTrials);
cd(oldPath); % Restore the cd

load(getappdata(fig,'logsheetPathMAT'),'logVar');
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);

subNames=fieldnames(allTrialNames);
setappdata(fig,'plotName',plotName); % For getArg
for sub=1:length(subNames)

    subName=subNames{sub};
    trialNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialNames)

        trialName=trialNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)
            % CREATE ONE FIGURE FOR EACH TRIAL            
            if ~isMovie
                plotStaticFig(fig,subName,trialName,repNum);
            else
                plotMovie(fig,subName,trialName,repNum);
            end

        end

    end

end