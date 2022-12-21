function []=setAxLims(fig,axHandle,axLims,plotName,records,currTrialInfo)

%% PURPOSE: SET THE AXES LIMITS FOR THE CURRENT AXES

% inclStruct=feval(specifyTrials);
% load(getappdata(fig,'logsheetPathMAT'),'logVar');

% VariableNamesList=getappdata(fig,'VariableNamesList');
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

    varNames=axLims.(dim).SaveNames;
    subvars=axLims.(dim).SubvarNames;

%     if contains(limLevel,'C')
%         org=1;        
%     else
%         org=0;
%     end
    
%     allTrialNames=getTrialNames(inclStruct,logVar,fig,org,[]);

    % Get the save names for the variables so I can load them from file.
    % 1. Get rid of the '(splitCode)' suffixes
    

    dimRecords=records.(dim);
%     if ~isempty(saveNames)
%         records=getPlotAxesLims(fig,allTrialNames,saveNames,subvars);
%     else
%         records=[NaN NaN];
%         limLevel='Z';
%     end

    % Get the subName and condNum for the current plot.
    if isstruct(currTrialInfo)
        subName=currTrialInfo.Subject;
        condNum=currTrialInfo.Condition;
        trialName=currTrialInfo.Trial;
    else % Not a trial-level plot.
        assert(isequal(limLevel,'P'));
    end

    if ~isstruct(dimRecords) && all(isnan(dimRecords))
        continue;
    end

    switch limLevel
        case 'P'
            dimRecords=dimRecords.All;
        case 'S' % Subject
            dimRecords=dimRecords.(subName);
        case 'C' % Condition
            dimRecords=dimRecords.Condition(condNum).Ex;
        case 'SC' % Subject-condition
            dimRecords=dimRecords.SubjectCondition(condNum).(subName);
        otherwise % Trial, or none provided.
%             if ~isHardCoded % 
%                 dimRecords=NaN;
%             elseif isHardCoded
%                 dimRecords=NaN; % Because this will just be whatever MATLAB defaults to.
%             end
    end        

%     if all(isnan(dimRecords)) && ~isHardCoded
%         continue;
%     end

    % Adjust the axes limits
    if ~isequal(Plotting.Plots.(plotName).Metadata.Level,'T')
        continue; % Need to implement subject, subject-condition, and condition levels.
    end

    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' getappdata(fig,'projectName') '.mat']; % Get the file name to load the data from
    if ~isempty(varNames)
        load(matFilePath,varNames{:}); % Load the specified data.

        minTrial=inf;
        maxTrial=-inf;
        for i=1:length(varNames)
            if ~isempty(subvars{i})
                data=eval([varNames{i} subvars{i}]);
            else
                data=eval(varNames{i});
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

        if isstruct(dimRecords) || (~isstruct(dimRecords) && isnan(dimRecords))
            dimRecords=maxTrial-minTrial; % For non-hardcoded values. If hardcoded, has already been handled.
        end
        meanValue=mean([minTrial maxTrial]);
        if ~isHardCoded
            setLims=true;
        else
            setLims=false;
        end
    else
        if isHardCoded
            setLims=true;
        else
            setLims=false;
        end
        if isscalar(dimRecords)
            meanValue=dimRecords/2;
        end
    end

    % In the future I can change how much outside of the bounds I want to show in the plot (scaling factor on records/2), and how much to translate it as well.
    lims=[meanValue-dimRecords/2 meanValue+dimRecords/2];

    if setLims
        axHandle.([dim 'Lim'])=lims; % Set the hard-coded axes limits
    end

end