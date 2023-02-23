function []=Template_Process_ST(subName,trialNames)

%% PURPOSE: PROCESSING FUNCTION

[data1]=getArg(1,subName);

for trialNum=1:length(trialNames)
    trialName=trialNames{trialNum};

    [data2]=getArg(2,subName,trialName,1);

end