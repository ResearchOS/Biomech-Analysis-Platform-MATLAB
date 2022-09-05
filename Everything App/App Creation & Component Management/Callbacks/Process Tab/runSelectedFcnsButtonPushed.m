function []=runSelectedFcnsButtonPushed(src,splitName_Code)

%% PURPOSE: RUN THE PROCESS FUNCTIONS SELECTED IN THE MAP FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
assignin('base','gui',fig);

if isempty(handles.Process.splitsUITree.SelectedNodes)
    beep;
    disp('Need to select a Split first!');
    return;
end

splitText=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitText,' ');
splitName=splitText(1:spaceIdx-1);
splitCode=splitText(spaceIdx+2:end-1);
setappdata(fig,'splitName',splitName);
setappdata(fig,'splitCode',splitCode);

%% 1. Get the list of relevant metadata for each function:
% function names
% node numbers (node row numbers?)
% specify trials names
% processing level (project/subject/trial
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');

fcnNodes=handles.Process.fcnArgsUITree.Children;

if isempty(fcnNodes)
    beep;
    disp('No functions selected!');
    return;
end

fcnNames=cell(length(fcnNodes),1);
nodeNums=NaN(length(fcnNodes),1);
for i=1:length(fcnNodes)
    fcnNames{i}=fcnNodes(i).Text;
    nodeNums(i)=fcnNodes(i).NodeData;
end

% if ismember('Logsheet',fcnNames)
%     disp('To import data from the logsheet, please go to the "Import" tab. This will not run now.');
%     nodeNums=nodeNums(~ismember(fcnNames,'Logsheet'));
%     fcnNames=fcnNames(~ismember(fcnNames,'Logsheet'));    
% end

nodeRows=ismember(Digraph.Nodes.NodeNumber,nodeNums);
coords=Digraph.Nodes.Coordinates(nodeRows,2);
specifyTrialsNames=Digraph.Nodes.SpecifyTrials(nodeRows);
isImportFcns=Digraph.Nodes.IsImport(nodeRows);
% assert(~any(diff(coords))==0 || length(coords)==1); % Check that no nodes have the same Y coordinate
[~,idx]=sort(coords,'descend'); % Sorted from highest to lowest

% fcnNames=Digraph.Nodes.FunctionNames(idx);
% nodeNums=D

fcnNames=fcnNames(idx);
nodeNums=nodeNums(idx);
specifyTrialsNames=specifyTrialsNames(idx);
isImportFcns=isImportFcns(idx);

emptySpecTrialsIdx=cellfun(@isempty,specifyTrialsNames);
if any(emptySpecTrialsIdx)
    disp('Missing specify trials in the following functions: ');
    return;
end

%% 2. Run the functions in order
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

setappdata(fig,'splitName',splitName);
setappdata(fig,'splitCode',splitCode);
macAddress=getComputerID();
logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT;
load(logsheetPathMAT,'logVar');
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

if ~ismember(handles.Import.subjIDColHeaderField.Value,logVar(1,:))
    beep;
    disp('The subject ID column header field was improperly entered!');
    return;
end

if ~ismember(handles.Import.targetTrialIDColHeaderField.Value,logVar(1,:))
    beep;
    disp('The target trial ID column header field was improperly entered!');
    return;
end

projectName=getappdata(fig,'projectName');
dataPath=getappdata(fig,'dataPath');

nodeRowNums=find(nodeRows==1);

for i=1:length(fcnNames)

    fcnName=fcnNames{i};
    nodeNum=nodeNums(i);
    specifyTrialsName=specifyTrialsNames{i};
    isImport=isImportFcns(i);
    level=readLevel([codePath 'Processing Functions' slash fcnName '.m'],isImport); % Look at the arguments of the processing function to determine what level to run it at    

    setappdata(fig,'nodeRow',nodeRowNums(i));

    inclStruct=feval(specifyTrialsName);
    trialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);

    oldPath=cd([codePath 'Processing Functions']);        

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

        if ismember('S',level)

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
    if runLog
        desc=['Ran function ' fcnName];
        updateLog(fig,desc,splitName_Code);
    end

end