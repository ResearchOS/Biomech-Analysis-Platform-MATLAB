function []=testProcess(subName,trialName,repNum)

%% PURPOSE: TEST GETARG AND SETARG

[var1,var2]=getArg(1,subName,trialName,repNum);

setArg(1,subName,trialName,repNum,var1,var2);