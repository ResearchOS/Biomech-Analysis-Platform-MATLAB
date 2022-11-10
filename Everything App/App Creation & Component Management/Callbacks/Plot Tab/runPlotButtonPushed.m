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

allTrialNamesNC=getTrialNames(inclStruct,logVar,fig,0,[]);
allTrialNamesC=getTrialNames(inclStruct,logVar,fig,1,[]);

setappdata(fig,'tabName','Plot');
setappdata(fig,'plotName',plotName); % For getArg

axLetters=fieldnames(Plotting.Plots.(plotName).Axes);
for axNum=1:length(axLetters)
    axLims=Plotting.Plots.(plotName).Axes.(axLetters{axNum}).AxLims;
    for dim='XYZ'
        varNames=axLims.(dim).SaveNames;
        subvars=axLims.(dim).SubvarNames;
        disp(['Axes ' axLetters{axNum} ' ' dim]);
        dimLevel=axLims.(dim).Level;
        if contains(dimLevel,'C')
            allTrialNames=allTrialNamesC;
        else
            allTrialNames=allTrialNamesNC;
        end
        if ~isempty(varNames)
            records.(axLetters{axNum}).(dim)=getPlotAxesLims(fig,allTrialNames,varNames,subvars);
        else
            records.(axLetters{axNum}).(dim)=NaN;
        end
    end
end

if contains(level,'C')
    allTrialNames=allTrialNamesC;
else
    allTrialNames=allTrialNamesNC;
end

if isequal(level,'P')    
    plotStaticFig_P(fig,allTrialNames); % Create one figure per project
    return;
end

if isequal(level,'PC')
    plotStaticFig_PC(fig,allTrialNames,records); % Create one figure per project, data split by condition.
    return;
end

if isequal(level,'C')
    plotStaticFig_C(fig,allTrialNames); % Create one figure per condition
    return;
end

subNames=fieldnames(allTrialNames);
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
            disp([plotName ' ' subName ' ' trialName ' ' num2str(repNum)]);

            % Determine which condition this trial is part of.
            for condNum=1:length(allTrialNamesC.Condition)
                subNames=fieldnames(allTrialNamesC.Condition(condNum));
                if ~ismember(subName,subNames)
                    continue; % Go on to the next trial.
                end
                currTrials=fieldnames(allTrialNamesC.Condition(condNum).(subName));
                if ismember(trialName,currTrials)
                    currTrialInfo.Condition=condNum;
                    break;
                end
            end
            currTrialInfo.Subject=subName;
            currTrialInfo.Trial=trialName;
            if ~isMovie
                plotStaticFig(fig,subName,trialName,repNum,records,currTrialInfo);
            else
                plotMovie(fig,subName,trialName,repNum,records,currTrialInfo);
            end

        end

    end

end