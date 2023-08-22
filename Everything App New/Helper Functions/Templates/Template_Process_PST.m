function []=Template_Process_PST(subNames,allTrialNames)

%% PURPOSE: PROCESSING FUNCTION

[data1]=getArg(1);

for subNum=1:length(subNames)
    subName=subNames{subNum};

    [data2]=getArg(2,subName);

    trialNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialNames)
        trialName=trialNames{trialNum};

        [data3]=getArg(3,subName,trialName,1);

    end

end