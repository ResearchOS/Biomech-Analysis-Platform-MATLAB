function [allData]=getPlotData(plotStructPS,subName,trialName)

%% PURPOSE: GET ALL OF THE DATA FOR THE CURRENT PLOT.

axes=plotStructPS.BackwardLinks_Component;

varNames={};
for i=1:length(axes)

    ax=axes{i};
    axPath=getClassFilePath(ax,'Component');
    axStruct=loadJSON(axPath);
    if ~isfield(axStruct,'BackwardLinks_Component')
        continue;
    end
    comps=axStruct.BackwardLinks_Component;

    for j=1:length(comps)
        comp=comps{j};
        compPath=getClassFilePath(comp,'Component');
        componentStruct=loadJSON(compPath);
        varNames=[varNames; getVarNamesArray(componentStruct,'InputVariables')];
    end

end

varNames=unique(varNames);
dataPath=getDataPath;

% Right now this assumes that all of the variables are trial level, which is a pretty good bet for things I'd want to plot.
allData=struct;
for i=1:length(varNames)
    allData.(varNames{i})=loadMAT(dataPath,varNames{i},subName,trialName);
end

assignin('base','allPlotData',allData);