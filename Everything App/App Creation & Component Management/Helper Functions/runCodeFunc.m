function []=runCodeFunc(gui,fcnName,splitName_Code,nodeNum)

%% PURPOSE: THIS IS THE RUNCODE FUNCTION THAT RUNS EACH PROCESSING FUNCTION.

Digraph=evalin('base','Digraph;');
% VariableNamesList=evalin('base','VariableNamesList;');
% NonFcnSettingsStruct=evalin('base','NonFcnSettingsStruct;');
projectSettingsMATPath=evalin('base','projectSettingsMATPath');
setappdata(gui,'projectSettingsMATPath',projectSettingsMATPath);
[codePath,~]=fileparts(projectSettingsMATPath);
dataPath=getappdata(gui,'dataPath');
projectName=getappdata(gui,'projectName');

load(getappdata(gui,'logsheetPathMAT'),'logVar');

slash=filesep;

nodeRows=find(ismember(Digraph.Nodes.NodeNumber,nodeNum)==1);

for rowCount=1:length(nodeRows)

    nodeRow=nodeRows(rowCount);

    splitNames_Codes=fieldnames(Digraph.Nodes.InputVariableNames{nodeRow});

    if ismember(splitName_Code,splitNames_Codes)
        break; % Have found the function to run.
    end
end

setappdata(gui,'nodeRow',nodeRow); % For getArg and setArg
underscoreIdx=strfind(splitName_Code,'_');
splitName=splitName_Code(1:underscoreIdx-1);
splitCode=splitName_Code(underscoreIdx+1:end);

setappdata(gui,'splitName',splitName);
setappdata(gui,'splitCode',splitCode);

specifyTrialsName=Digraph.Nodes.SpecifyTrials{nodeRow};
isImport=Digraph.Nodes.IsImport(nodeRow);
level=readLevel([codePath slash 'Processing Functions' slash fcnName '.m'],isImport);

inclStruct=feval(specifyTrialsName);
trialNames=getTrialNames(inclStruct,logVar,gui,0,[]);
subNames=fieldnames(trialNames);

oldPath=cd([codePath slash 'Processing Functions']);
projectStruct=[];

if ismember('P',level)

    disp(['Running ' fcnName ' ' splitName_Code]);

    if ismember('T',level)
        feval(fcnName,projectStruct,trialNames);
    elseif ismember('S',level)
        feval(fcnName,projectStruct,subNames);
    else
        feval(fcnName,projectStruct);
    end
end

for sub=1:length(subNames)
    subName=subNames{sub};
    currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

    if ismember('S',level)

        disp(['Running ' fcnName ' ' splitName_Code ' Subject ' subName]);

        if ismember('Trial',currLevels)
            feval(fcnName,projectStruct,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
        else
            feval(fcnName,projectStruct,subName);
        end
        continue; % Don't iterate through trials, that's done within the processing function if necessary
    end

    for trialNum=1:length(currTrials)
        trialName=currTrials{trialNum};

        disp(['Running ' fcnName ' ' splitName_Code ' Subject ' subName ' Trial ' trialName]);

        for repNum=trialNames.(subName).(trialName)

            if ~isImport
                feval(fcnName,projectStruct,subName,trialName,repNum); % projectStruct is an input argument for convenience of viewing the data only
            else
                filePath=[dataPath subName slash trialName '_' subName '_' projectName '.c3d'];
                feval(fcnName,filePath,projectStruct,subName,trialName,repNum);
            end

        end
    end

end

cd(oldPath);