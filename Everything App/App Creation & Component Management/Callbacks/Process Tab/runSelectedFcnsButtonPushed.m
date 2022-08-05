function []=runSelectedFcnsButtonPushed(src,event)

%% PURPOSE: RUN THE PROCESS FUNCTIONS SELECTED IN THE MAP FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
assignin('base','gui',fig);

if isempty(handles.Process.splitsUITree.SelectedNodes)
    beep;
    disp('Need to select a Split first!');
    return;
end

%% 1. Get the list of relevant metadata for each function:
% function names
% node numbers (node row numbers?)
% specify trials names
% processing level (project/subject/trial
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');

fcnNodes=handles.Process.fcnArgsUITree.Children;

fcnNames=cell(length(fcnNodes),1);
nodeNums=NaN(length(fcnNodes),1);
for i=1:length(fcnNodes)
    fcnNames{i}=fcnNodes(i).Text;
    nodeNums(i)=fcnNodes(i).NodeData;
end

nodeRows=ismember(Digraph.Nodes.NodeNumber,nodeNums);
coords=Digraph.Nodes.Coordinates(nodeRows,2);
specifyTrialsNames=Digraph.Nodes.SpecifyTrials(nodeRows);
isImportFcns=Digraph.Nodes.IsImport(nodeRows);
assert(~any(diff(coords))==0 || length(coords)==1); % Check that no nodes have the same Y coordinate
[~,idx]=sort(coords,'descend'); % Sorted from highest to lowest

% fcnNames=Digraph.Nodes.FunctionNames(idx);
% nodeNums=D

fcnNames=fcnNames(idx);
nodeNums=nodeNums(idx);
specifyTrialsNames=specifyTrialsNames(idx);
isImportFcns=isImportFcns(idx);

emptySpecTrialsIdx=cellfun(@isempty,specifyTrialsNames);
if any(emptySpecTrialsIdx)
    disp('Missing specify trials in the following functions:');
    return;
end

%% 2. Run the functions in order
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

splitName=handles.Process.splitsUITree.SelectedNodes.Text;
splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;

setappdata(fig,'splitName',splitName);
setappdata(fig,'splitCode',splitCode);
macAddress=getComputerID();
logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT;
load(logsheetPathMAT,'logsheetVar');
codePath=getappdata(fig,'codePath');
if exist('projectStruct','var')~=1
    projectStruct=[];
end

% Check that the logsheet is all set up properly
if handles.Import.numHeaderRowsField.Value<0
    beep;
    disp('Ensure that the number of headers rows is properly entered!');
    return;
end

if ~ismember(handles.Import.subjIDColHeaderField.Value,logsheetVar(1,:))
    beep;
    disp('The subject ID column header field was improperly entered!');
    return;
end

if ~ismember(handles.Import.targetTrialIDColHeaderField.Value,logsheetVar(1,:))
    beep;
    disp('The target trial ID column header field was improperly entered!');
    return;
end

projectName=getappdata(fig,'projectName');
dataPath=getappdata(fig,'dataPath');

for i=1:length(fcnNames)

    fcnName=fcnNames{i};
    nodeNum=nodeNums(i);
    specifyTrialsName=specifyTrialsNames{i};
    isImport=isImportFcns(i);
    level=readLevel([codePath 'Processing Functions' slash fcnName '.m'],isImport); % Look at the arguments of the processing function to determine what level to run it at    

    setappdata(fig,'currNodeNum',nodeNum);

    inclStruct=feval(specifyTrialsName);
    trialNames=getTrialNames(inclStruct,logsheetVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);

    oldPath=cd(codePath);        

    if ismember('P',level)

        disp(['Running ' fcnName ' ' splitName]);

        if ismember('T',level)
            feval(fcnName,projectStruct,trialNames);
        elseif ismember('S',level)
            feval(fcnName,projectStruct,subNames);
        else
            feval(fcnName,projectStruct);
        end
        continue;
    end

    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        if ismember('Subject',level)

            disp(['Running ' fcnName ' ' splitName ' Subject ' subName]);

            if ismember('Trial',currLevels)
                feval(fcnName,projectStruct,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
            else
                feval(fcnName,projectStruct,subName);
            end
            continue; % Don't iterate through trials, that's done within the processing function if necessary
        end

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            disp(['Running ' fcnName ' ' splitName ' Subject ' subName ' Trial ' trialName]);

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

    % Create log of the function that just successfully finished running.
    disp(['Now Logging ' fcnName ' ' splitName])
    generateLog(nodeNum);
    disp(['Finished Logging ' fcnName ' ' splitName])

end