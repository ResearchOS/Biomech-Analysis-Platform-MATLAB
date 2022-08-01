function []=runSelectedFcnsButtonPushed(src,event)

%% PURPOSE: RUN THE PROCESS FUNCTIONS SELECTED IN THE MAP FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
assignin('base','gui',fig);

%% 1. Get the list relevant metadata for each function:
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
assert(~any(diff(coords))==0 || length(coords)==1); % Check that no nodes have the same Y coordinate
[~,idx]=sort(coords,'descend'); % Sorted from highest to lowest

fcnNames=fcnNames(idx);
nodeNums=nodeNums(idx);

%% 2. Run the functions in order
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

splitName=handles.Process.splitsUITree.CheckedNodes.Text; % Checked or selected?
splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;

setappdata(fig,'splitName',splitName);
macAddress=getComputerID();
logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT;
load(logsheetPathMAT,'logsheetVar');
codePath=getappdata(fig,'codePath');
for i=1:length(fcnNames)

    fcnName=fcnNames{i};
    nodeNum=nodeNums(i);
%     specTrialsName=specTrialsNames{i};
    level=readLevel([codePath 'Processing Functions' slash fcnName '.m']);

    setappdata(fig,'currNodeNum',nodeNum);

    inclStruct=feval(specTrialsName);
    trialNames=getTrialNames(inclStruct,logsheetVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);

    if ismember('P',level)

        disp(['Running ' fcnName ' ' splitName]);

        if ismember('T',level)
            feval(fcnName,projectStruct,trialNames);
        elseif ismember('S',currLevels)
            feval(fcnName,projectStruct,subNames);
        else
            feval(fcnName,projectStruct);
        end
        continue;
    end

    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        if ismember('Subject',currLevels)

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

                feval(fcnName,projectStruct,subName,trialName,repNum); % projectStruct is an input argument for convenience of viewing the data only

            end
        end

    end

    % Create log of the function that just successfully finished running.
    disp(['Now Logging ' fcnName ' ' splitName])
    generateLog(nodeNum);
    disp(['Finished Logging ' fcnName ' ' splitName])

end