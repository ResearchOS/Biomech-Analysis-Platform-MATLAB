function []=runPlotButtonPushed(src,event)

%% PURPOSE: RUN THE PLOTS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

assignin('base','gui',fig);

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

level=Plotting.Plots.(plotName).Metadata.Level;

load(getappdata(fig,'logsheetPathMAT'),'logVar');
if contains(level,'C')
    org=1; % Organize trial names by condition & subject
else
    org=0; % Organize trial names all together by subject
end

allTrialNames=getTrialNames(inclStruct,logVar,fig,org,[]);

setappdata(fig,'tabName','Plot');

if isequal(level,'P')    
    plotStaticFig_P(fig,allTrialNames); % Create one figure per project
    return;
end

if isequal(level,'PC')
    plotStaticFig_PC(fig,allTrialNames); % Create one figure per project, data split by condition.
    return;
end

if isequal(level,'C')
    plotStaticFig_C(fig,allTrialNames); % Create one figure per condition
    return;
end

subNames=fieldnames(allTrialNames);
setappdata(fig,'plotName',plotName); % For getArg
for sub=1:length(subNames)

    subName=subNames{sub};

    if isequal(level,'S') % Create one figure per subject
        plotStaticFig_S(fig,allTrialNames.(subName));
        return;
    elseif isequal(level,'SC') % Create one figure per subject
        plotStaticFig_SC(fig,allTrialNames.Condition,subName);
        return;
    end

    %% NOTE: NEED A SELECTION FOR CREATING ONE FIGURE PER SUBJECT & CONDITION (E.G. 10 SUBS & 3 CONDITIONS = 30 FIGURES)
    
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