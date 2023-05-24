function [h]=Template_Component_PC(ax,allTrialNames,plotName)

%% PURPOSE: PLOT COMPONENT

numConds=length(allTrialNames.Condition);
condNames=genvarname(condNames);

[data]=getArg(1);

h=[];