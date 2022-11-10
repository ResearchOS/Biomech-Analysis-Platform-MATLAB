function []=setAxLims(fig,axHandle,axLims,plotName,specifyTrials)

%% PURPOSE: SET THE AXES LIMITS FOR THE CURRENT AXES

inclStruct=feval(specifyTrials);
load(getappdata(fig,'logsheetPathMAT'),'logVar');

VariableNamesList=getappdata(fig,'VariableNamesList');
Plotting=getappdata(fig,'Plotting');

slash=filesep;

for dim='XYZ' % Iterate over each dimension

    limLevel=axLims.(dim).Level;
    isHardCoded=axLims.(dim).IsHardCoded;
    if iscell(axLims.(dim).VariableValue)
        value=axLims.(dim).VariableValue{1};
    else
        value=axLims.(dim).VariableValue;
    end

    if isHardCoded==1
        assert(isequal(limLevel,'P'));
        axHandle.([dim 'Lim'])=eval(value); % Set the hard-coded axes limits
        continue;
    end

    varNames=axLims.(dim).VariableNames;
    subvars=axLims.(dim).SubvarNames;

    if contains(limLevel,'C')
        org=1;        
    else
        org=0;
    end
    
    allTrialNames=getTrialNames(inclStruct,logVar,fig,org,[]);

    % Get the save names for the variables so I can load them from file.
    % 1. Get rid of the '(splitCode)' suffixes
    cutVarNames=cell(length(varNames),1);
    splitCodes=cell(length(varNames),1);
    for i=1:length(cutVarNames)
        spaceIdx=strfind(varNames{i},' ');
        cutVarNames{i}=varNames{i}(1:spaceIdx-1);
        splitCodes{i}=varNames{i}(spaceIdx+2:end-1);
    end

    % 2. Get the corresponding save names
    [~,a,~]=intersect(VariableNamesList.GUINames,cutVarNames,'stable');
    saveNames=VariableNamesList.SaveNames(a);

    % 3. Append the split codes to them
    for i=1:length(saveNames)
        saveNames{i}=[saveNames{i} '_' splitCodes{i}];
    end

%     dimRecords=records.(dim).(limLevel);
    if ~isempty(saveNames)
        records=getPlotAxesLims(fig,allTrialNames,saveNames,subvars);
    else
        records=[NaN NaN];
        limLevel='Z';
    end

    % Get the subName and condNum for the current plot.
    subName=Plotting.Plots.(plotName).ExTrial.Subject;
    condNum=Plotting.Plots.(plotName).ExTrial.Condition;
    trialName=Plotting.Plots.(plotName).ExTrial.Trial;

    switch limLevel
        case 'P'
            records=records.All;
        case 'S' % Subject
            records=records.(subName);
        case 'C' % Condition
            records=records.Condition(condNum).Ex;
        case 'SC' % Subject-condition
            records=records.SubjectCondition(condNum).(subName);
        otherwise % Trial, or none provided.
            records=[NaN NaN]; % Because this will just be whatever MATLAB defaults to.
    end    

    if all(isnan(records))
        continue;
    end

    % Adjust the axes limits
    if ~isequal(Plotting.Plots.(plotName).Metadata.Level,'T')
        continue; % Need to implement subject, subject-condition, and condition levels.
    end

    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' getappdata(fig,'projectName') '.mat']; % Get the file name to load the data from
    load(matFilePath,saveNames{:}); % Load the specified data.

    minTrial=inf;
    maxTrial=-inf;
    for i=1:length(saveNames)
        if ~isempty(subvars{i})
            data=eval([saveNames{i} subvars{i}]);
        else
            data=eval(saveNames{i});
        end

        minData=min(data,[],'omitnan');
        maxData=max(data,[],'omitnan');

        if minTrial>minData
            minTrial=minData;
        end
        if maxTrial<maxData
            maxTrial=maxData;
        end
    end

    % In the future I can change how much outside of the bounds I want to show in the plot (scaling factor on records/2), and how much to translate it as well.
    lims=[mean([minTrial maxTrial])-records/2 mean([minTrial maxTrial])+records/2];
    axHandle.([dim 'Lim'])=lims; % Set the hard-coded axes limits

end