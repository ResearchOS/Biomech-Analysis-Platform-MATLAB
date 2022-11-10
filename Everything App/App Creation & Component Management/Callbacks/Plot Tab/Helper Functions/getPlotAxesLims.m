function [records]=getPlotAxesLims(fig,allTrialNames,varNames,subvars)

%% PURPOSE: RETURN THE AXES LIMITS AT EVERY LEVEL FOR THE SPECIFIED TRIALS.
defInf=-inf; % Default values are infinity
records.All=defInf;

if isfield(allTrialNames,'Condition')
    isCond=1;
else
    isCond=0;
end

slash=filesep;
projectName=getappdata(fig,'projectName');
dataPath=getappdata(fig,'dataPath');

if isCond==0
    subNames=fieldnames(allTrialNames);

    for sub=1:length(subNames) % Iterate through each subject
        subName=subNames{sub};
        currTrials=fieldnames(allTrialNames.(subName));

        records.Subject.(subName)=defInf;

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            for repNum=allTrialNames.(subName).(trialName)

                matFilePath=[dataPath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat']; % Get the file name to load the data from
                load(matFilePath,varNames{:}); % Load the specified data.
                minTrial=inf;
                maxTrial=-inf;
                for varNum=1:length(varNames)
                    varName=varNames{varNum};
                    subVar=subvars{varNum};

                    if ~isempty(subVar)
                        data=eval([varName subVar]); % Index into subvar
                    else
                        data=eval(varName);
                    end

                    minData=min(data,[],'omitnan');
                    maxData=max(data,[],'omitnan');

                    if minData<minTrial
                        minTrial=minData;
                    end

                    if maxData>maxTrial
                        maxTrial=maxData;
                    end

                end

                trialDiff=maxTrial-minTrial;

                % Set new records, if applicable
                if records.All<trialDiff
                    records.All=trialDiff;
                end
%                 if records.All(1)>minTrial
%                     records.All(1)=minTrial;
%                 end
%                 if records.All(2)<maxTrial
%                     records.All(2)=maxTrial;
%                 end

                if records.Subject.(subName)<trialDiff
                    records.Subject.(subName)=trialDiff;
                end

%                 if records.Subject.(subName)(1)>minTrial
%                     records.Subject.(subName)(1)=minTrial;
%                 end
%                 if records.Subject.(subName)(2)<maxTrial
%                     records.Subject.(subName)(2)=maxTrial;
%                 end

            end
        end
    end

    return; % Finished with axis limits without conditions.

end

%% Get records if specified by condition
for condNum=1:length(allTrialNames.Condition)
    currCond=allTrialNames.Condition(condNum);
    records.Condition(condNum).Ex=defInf;
    subNames=fieldnames(currCond);

    for subNum=1:length(subNames)
        subName=subNames{subNum};
        currTrials=fieldnames(currCond.(subName));

        records.Subject.(subName)=defInf;
        records.SubjectCondition(condNum).(subName)=defInf;

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            for repNum=currCond.(subName).(trialName)

                matFilePath=[dataPath 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat']; % Get the file name to load the data from
                load(matFilePath,varNames{:}); % Load the specified data.
                minTrial=inf;
                maxTrial=-inf;
                for varNum=1:length(varNames)
                    varName=varNames{varNum};
                    subVar=subvars{varNum};

                    if ~isempty(subVar)
                        data=eval([varName subVar]); % Index into subvar
                    else
                        data=eval(varName);
                    end

                    minData=min(data,[],'omitnan');
                    maxData=max(data,[],'omitnan');

                    if minData<minTrial
                        minTrial=minData;
                    end

                    if maxData>maxTrial
                        maxTrial=maxData;
                    end

                end

                trialDiff=maxTrial-minTrial;

                % Set new records, if applicable
                if records.All<trialDiff
                    records.All=trialDiff;
                end
%                 if records.All(1)>minTrial
%                     records.All(1)=minTrial;
%                 end
%                 if records.All(2)<maxTrial
%                     records.All(2)=maxTrial;
%                 end

                if records.Subject.(subName)<trialDiff
                    records.Subject.(subName)=trialDiff;
                end
%                 if records.Subject.(subName)(1)>minTrial
%                     records.Subject.(subName)(1)=minTrial;
%                 end
%                 if records.Subject.(subName)(2)<maxTrial
%                     records.Subject.(subName)(2)=maxTrial;
%                 end

                if records.Condition(condNum).Ex<trialDiff
                    records.Condition(condNum).Ex=trialDiff;
                end
%                 if records.Condition(condNum).Ex(1)>minTrial
%                     records.Condition(condNum).Ex(1)=minTrial;
%                 end
%                 if records.Condition(condNum).Ex(2)<maxTrial
%                     records.Condition(condNum).Ex(2)=maxTrial;
%                 end

                if records.SubjectCondition(condNum).(subName)<trialDiff
                    records.SubjectCondition(condNum).(subName)=trialDiff;
                end
%                 if records.SubjectCondition(condNum).(subName)(1)>minTrial
%                     records.SubjectCondition(condNum).(subName)(1)=minTrial;
%                 end
%                 if records.SubjectCondition(condNum).(subName)(2)<maxTrial
%                     records.SubjectCondition(condNum).(subName)(2)=maxTrial;
%                 end

            end

        end

    end

end