function []=Template_Process_T(subName,trialName,repNum)

%% PURPOSE: PROCESSING FUNCTION

[data]=getArg(1,subName,trialName,repNum);



setArg(1,subName,trialName,repNum,data);