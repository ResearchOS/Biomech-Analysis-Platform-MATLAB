function []=plotButtonPushed(src,event)

%% PURPOSE: PLOT ALL SPECIFIED DATA.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
plotName=projectSettings.Current_Plot_Name;

fullPath=getClassFilePath(plotName, 'Plot');
plotStructPS=loadJSON(fullPath);

[plotNamePI,id]=deText(plotName);
plotNamePI=[plotNamePI '_' id];
fullPathPI=getClassFilePath(plotNamePI, 'Plot');
plotStructPI=loadJSON(fullPathPI);

level=plotStructPS.Level; % How often the plot function is called.
multi=plotStructPS.Multi; % How many trials/subjects/conditions to put on each plot. Same valid values as "level"
isMovie=plotStructPI.IsMovie; % Whether this is a static plot or a movie.
if isMovie==1
    level='T'; % Overriden because movies can only be trial level (currently)
    multi='T';
end

opts={'T','SC','S','C','PC','P'}; % In order lowest to highest
multiIdx=find(ismember(opts,multi)==1);
levelIdx=find(ismember(opts,level)==1);
if levelIdx==length(opts) && isempty(multiIdx)
    multiIdx=length(opts);
end
assert(~isempty(multiIdx) && ~isempty(levelIdx));
if multiIdx<levelIdx
    error('''Multi'' must be a higher or equal level than ''Level''');
end

%% Get the data path
dataPath=getDataPath();

%% Compute the desired axes limits
% 1. Get the components whose variables should be used to compute the axes limits.

%% Specify trials
specifyTrials=plotStructPS.SpecifyTrials;
inclStruct=getInclStruct(specifyTrials);

logsheetText=handles.Import.allLogsheetsUITree.SelectedNodes.Text;
logPath=getClassFilePath(logsheetText, 'Logsheet');
logsheetStruct=loadJSON(logPath);
isCond=contains(multi,'C') | contains(level,'C');
computerID=getComputerID();
logsheetPath=logsheetStruct.LogsheetPath.(computerID);
[logFolder,logName]=fileparts(logsheetPath);
logsheetPathMAT=[logFolder filesep logName '.mat'];
load(logsheetPathMAT,'logVar');
allTrialNames=getTrialNames(inclStruct, logVar, isCond, logsheetStruct);

if ~isCond
    subNames=fieldnames(allTrialNames);
    numConds=1;
else
    numConds=length(allTrialNames.Condition);
end

if contains(multi,'P')
    Q=figure;
    currFig=Q;
end
if contains(level,'P')
    plotComponents(currFig,isMovie,plotStructPS,allTrialNames);
    saveCurrentFigure(currFig,plotStructPS);
    return;
end
for condNum=1:numConds

    if isequal(multi,'C')
        Q(condNum)=figure('Name',['Condition ' num2str(condNum)]);
        currFig=Q(condNum);
    end

    if isequal(level,'C')
        plotComponents(currFig,isMovie,plotStructPS,allTrialNames.Condition(condNum));
        saveCurrentFigure(currFig,plotStructPS);
        continue;
    end

    if contains(level,'C')
        subNames=fieldnames(allTrialNames.Condition(condNum));
    end

    for subNum=1:length(subNames)

        subName=subNames{subNum};
        if ~isCond
            trialNames=fieldnames(allTrialNames.(subName));
        else
            trialNames=fieldnames(allTrialNames.Condition(condNum).(subName));
        end

        if isequal(multi,'S')
            Q.(subName)=figure('Name',subName);
            currFig=Q.(subName);            
        elseif isequal(multi,'SC')
            Q(condNum).(subName)=figure('Name',['Condition ' num2str(condNum) ' ' subName]);
            currFig=Q(condNum).(subName);
        end

        if ismember(level,{'S','SC'})
            plotComponents(currFig,isMovie,plotStructPS,subName,trialNames);
            continue;
        end        

        for trialNum=1:length(trialNames)
            trialName=trialNames{trialNum};

            % 1. Create figure
            if isequal(multi,'T')                
                % Need to allow the user to create a default figure name
                % (and a default save name for that matter)
                taskType=loadArg(dataPath,subName,trialName,1,'Trial_Type_Task_2452AA_6C0');
                Q.(subName).(trialName)=figure('Name',[subName '_' trialName '_' taskType]);
                currFig=Q.(subName).(trialName);
            elseif isequal(multi,'SC')
                currFig=Q(condNum).(subName);
            elseif isequal(multi,'S')
                currFig=Q.(subName);
            elseif isequal(multi,'C')
                currFig=Q(condNum);
            elseif isequal(multi,'P')
                currFig=Q;
            end

            % 2. Plot the components
            plotComponents(currFig,isMovie,plotStructPS,subName,trialName,1);

            if isequal(multi,'T') && ~isMovie
                saveCurrentFigure(currFig,plotStructPS);
            end

        end

        if ismember(multi,{'S','SC'})
            saveCurrentFigure(currFig,plotStructPS);
        end

    end

    if isequal(multi,'C')
        saveCurrentFigure(currFig,plotStructPS);
    end

end