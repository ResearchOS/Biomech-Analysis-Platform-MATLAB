function []=addFuncRunCode(fcnName,fcnSplit,inputVarNames,inputVarNamesInCode,isHardCoded,outputVarNames,outputVarNamesInCode,nodeNumber,specifyTrials,runOrder,prevFcnNodeNumber,isImport,coordinate)

%% PURPOSE: FROM THE RUN CODE, ADD A FUNCTION (& VARIABLES) TO THE SETTINGS VARIABLES.
% Each input variable corresponds to one column of the Digraph Nodes table.
fig=evalin('base','runCodeHiddenGUI;');

try
    VariableNamesList=evalin('base','VariableNamesList;');
catch
    disp('VariableNamesList missing from base workspace, initializing as empty!');
    VariableNamesList.GUINames=cell(0,1);
    VariableNamesList.SaveNames=cell(0,1);
    VariableNamesList.SplitNames=cell(0,1);
    VariableNamesList.SplitCodes=cell(0,1);
    VariableNamesList.Descriptions=cell(0,1);
    VariableNamesList.Level=cell(0,1);
    VariableNamesList.IsHardCoded=cell(0,1);
end

try
    Digraph=evalin('base','Digraph;');
catch
    disp('Digraph missing from base workspace, initializing as empty!');
    Digraph=digraph;
    Digraph=addnode(Digraph,1);
    Digraph.Nodes.FunctionNames={'Logsheet'};
    Digraph.Nodes.Descriptions={{''}};
    Digraph.Nodes.InputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.OutputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.Coordinates=[0 0];  
%     Digraph.Nodes.SplitCodes={{'001'}};
    Digraph.Nodes.NodeNumber=1;
    Digraph.Nodes.SpecifyTrials={''};
    Digraph.Nodes.IsImport=false;
    Digraph.Nodes.InputVariableNamesInCode{1}=''; % Name in file/code
    Digraph.Nodes.OutputVariableNamesInCode{1}=''; % Name in file/code
end

try
    projectSettingsMATPath=evalin('base','projectSettingsMATPath;');
catch
    disp('Missing the projectSettingsMATPath variable from the base workspace! Stopping.');
    return;
end
    
%% Add the function to the Digraph. If the node number already exists, modify that row instead of creating a new one at the end.
if ~ismember(nodeNumber,Digraph.Nodes.NodeNumber) % Add a new node
    Digraph=addnode(Digraph,1);
    Digraph.Nodes.FunctionNames{end}=fcnName;
    Digraph.Nodes.Descriptions{end}={''};
    Digraph.Nodes.Coordinates(end,:)=coordinate;
    Digraph.Nodes.InputVariableNames{end}.(fcnSplit)=inputVarNames;
    Digraph.Nodes.OutputVariableNames{end}.(fcnSplit)=outputVarNames;
    % Digraph.Nodes.SplitCodes{end}={splitCode};
    Digraph.Nodes.SpecifyTrials{end}=specifyTrials;    
    Digraph.Nodes.NodeNumber(end)=nodeNumber; % Helps to differentiate nodes of the same function name
    Digraph.Nodes.InputVariableNamesInCode{end}.(fcnSplit)=inputVarNamesInCode; % Name in file/code
    Digraph.Nodes.OutputVariableNamesInCode{end}.(fcnSplit)=outputVarNamesInCode; % Name in file/code
    Digraph.Nodes.IsImport(end)=false; 
    Digraph.Nodes.RunOrder{end}.(fcnSplit)=runOrder;
    rowIdx=length(Digraph.Nodes.NodeNumber);
else % Modify existing node
    rowIdx=find(ismember(Digraph.Nodes.NodeNumber,nodeNumber)==1);
    Digraph.Nodes.FunctionNames{rowIdx}=fcnName;
%     Digraph.Nodes.Descriptions{rowIdx}='';
    Digraph.Nodes.InputVariableNames{rowIdx}.(fcnSplit)=inputVarNames;
    Digraph.Nodes.OutputVariableNames{rowIdx}.(fcnSplit)=outputVarNames;
    Digraph.Nodes.Coordinates(rowIdx,:)=coordinate;
    Digraph.Nodes.NodeNumber(rowIdx)=nodeNumber;
    Digraph.Nodes.SpecifyTrials{rowIdx}=specifyTrials;
    Digraph.Nodes.IsImport(rowIdx)=isImport;
    Digraph.Nodes.InputVariableNamesInCode{rowIdx}.(fcnSplit)=inputVarNamesInCode;
    Digraph.Nodes.OutputVariableNamesInCode{rowIdx}.(fcnSplit)=outputVarNamesInCode;
    Digraph.Nodes.RunOrder{rowIdx}.(fcnSplit)=runOrder;
end

%% Add new edge to the Digraph.
prevRowIdx=find(ismember(Digraph.Nodes.NodeNumber,prevFcnNodeNumber)==1);
varNames=Digraph.Edges.Properties.VariableNames;
if ismember('NodeNumber',varNames)
    if ~ismember([prevFcnNodeNumber nodeNumber],Digraph.Edges.NodeNumber,'rows') % Skip adding an edge if the edge has already been added
        Digraph=addedge(Digraph,prevRowIdx,rowIdx);
        edgeIdx=length(Digraph.Edges);
        Digraph.Edges.FunctionNames{edgeIdx,1}=Digraph.Nodes.FunctionNames{prevRowIdx};
        Digraph.Edges.FunctionNames{edgeIdx,2}=Digraph.Nodes.FunctionNames{rowIdx};
        Digraph.Edges.NodeNumber(edgeIdx,1)=Digraph.Nodes.NodeNumber(prevRowIdx);
        Digraph.Edges.NodeNumber(edgeIdx,2)=Digraph.Nodes.NodeNumber(rowIdx);
        underscoreIdx=strfind(fcnSplit,'_');
        splitCode=fcnSplit(underscoreIdx+1:end);
        Digraph.Edges.SplitCodes{edgeIdx}=splitCode;
        Digraph.Edges.Color(edgeIdx,:)=[0 0.4470 0.7410];        
        splitRows=find(ismember(Digraph.Edges.SplitCode,splitCode)==1);
        Digraph.Edges.Color(edgeIdx,:)=Digraph.Edges.Color(splitRows(1),:);        
    end
else % Initializing the Digraph edges
    Digraph=addedge(Digraph,prevRowIdx,rowIdx);
    edgeIdx=size(Digraph.Edges.EndNodes,1);
    Digraph.Edges.FunctionNames{edgeIdx,1}=Digraph.Nodes.FunctionNames{prevRowIdx};
    Digraph.Edges.FunctionNames{edgeIdx,2}=Digraph.Nodes.FunctionNames{rowIdx};
    Digraph.Edges.NodeNumber(edgeIdx,1)=Digraph.Nodes.NodeNumber(prevRowIdx);
    Digraph.Edges.NodeNumber(edgeIdx,2)=Digraph.Nodes.NodeNumber(rowIdx);
    Digraph.Edges.SplitCodes{edgeIdx}='001';
    Digraph.Edges.Color(edgeIdx,:)=[0 0.4470 0.7410];
end

assignin('base','Digraph',Digraph);
setappdata(fig,'Digraph',Digraph);
save(projectSettingsMATPath,'Digraph','-append');

%% Check for variables that are not yet represented in the VariableNamesList. If there are any, add them to the VariableNamesList.
guiNames=VariableNamesList.GUINames;

inputVarNamesVarList=cell(length(inputVarNames),1); % Initialize the cell array that will hold the variable GUI names with split code excluded
outputVarNamesVarList=cell(length(outputVarNames),1);
inputVarNamesSaveNames=cell(length(inputVarNames),1); % Initialize the cell array that will hold the variable save names with split code excluded
outputVarNamesSaveNames=cell(length(outputVarNames),1);

for i=1:length(inputVarNames)
    spaceIdx=strfind(inputVarNames{i},' ');
    inputVarNamesVarList{i}=inputVarNames{i}(1:spaceIdx(end)-1);
    inputVarNamesSaveNames{i}=genvarname(inputVarNamesVarList{i});
end
for i=1:length(outputVarNames)
    spaceIdx=strfind(outputVarNames{i},' ');
    outputVarNamesVarList{i}=outputVarNames{i}(1:spaceIdx(end)-1);
    outputVarNamesSaveNames{i}=genvarname(outputVarNamesVarList{i});
end

if all(ismember(inputVarNamesVarList,guiNames)) && all(ismember(outputVarNamesVarList,guiNames))
    return; % There are no new variables here, don't do anything else, the function has been fully added.
end

newVarNames={}; % All input & output vars GUI names (so that I can add them all to the VariableNamesList at once)
newSaveVarNames={}; % All input & output vars save names
newVarNamesSuffix={};

if any(~ismember(inputVarNamesVarList,guiNames)) % At least one of the input variables are new.
    newVarIdx=~ismember(inputVarNamesVarList,guiNames); % The idx of the new variables.
    newVarNames=[newVarNames; inputVarNamesVarList(newVarIdx)]; 
    newSaveVarNames=[newSaveVarNames; inputVarNamesSaveNames(newVarIdx)]; 
%     newVarNames=[newVarNames; inputVarNamesVarList]; 
%     newSaveVarNames=[newSaveVarNames; inputVarNamesSaveNames];   
    newVarNamesSuffix=[newVarNamesSuffix; inputVarNames(newVarIdx)];
end

if any(~ismember(outputVarNamesVarList,guiNames))
    newVarIdx=~ismember(outputVarNamesVarList,guiNames); % The idx of the new variables.
    newVarNames=[newVarNames; outputVarNamesVarList(newVarIdx)]; 
    newSaveVarNames=[newSaveVarNames; outputVarNamesSaveNames(newVarIdx)];
%     newVarNames=[newVarNames; outputVarNamesVarList]; 
%     newSaveVarNames=[newSaveVarNames; outputVarNamesSaveNames];
    newVarNamesSuffix=[newVarNamesSuffix; outputVarNames(newVarIdx)];
end

% Add the variable GUI names
VariableNamesList.GUINames=[VariableNamesList.GUINames; newVarNames];
VariableNamesList.GUINames=unique(VariableNamesList.GUINames,'stable');

% Add the variable names in code
VariableNamesList.SaveNames=[VariableNamesList.SaveNames; newSaveVarNames];
VariableNamesList.SaveNames=unique(VariableNamesList.SaveNames,'stable');

% Add the split names & codes
for i=1:length(newVarNamesSuffix)
    spaceIdx=strfind(newVarNamesSuffix{i},' ');
%     splitName=newVarNamesSuffix{i}(1:spaceIdx(end)-1);
    splitCode=newVarNamesSuffix{i}(spaceIdx(end)+2:end-1);
    varRow=ismember(VariableNamesList.GUINames,newVarNames{i});
    if ~any(varRow)
        varRow=length(VariableNamesList.GUINames)+1;
    end
    % 09/28/2022 This will work to hand the code off to Zahava, but essentially I am
    % giving up for now. In run code format, there is currently no mechanism to add a
    % new split with a name and a code. That would need to be added to the
    % NonFcnSettingsStruct, and is a whole nother thing. In the handoff
    % code I only have the two splits, hence the hard-coding.
    if isequal(splitCode,'001')
        splitName='Default';
    else
        splitName='MOS';
    end
    VariableNamesList.SplitNames{varRow,1}=splitName;
    VariableNamesList.SplitCodes{varRow,1}=splitCode;
    VariableNamesList.Descriptions{varRow,1}='Enter Arg Description Here';
    VariableNamesList.Level{varRow,1}='T'; % Default to trial level variable. This currently doesn't have any real importance, so this is ok
    VariableNamesList.IsHardCoded{varRow,1}=0; % Default to not hard coded. This will need to be changed in the settings var (& the var to be created) as needed.
end

if exist('isHardCoded','var')==1
    [~,varsIdx,varsIdxB]=intersect(VariableNamesList.GUINames,inputVarNamesVarList);
    VariableNamesList.IsHardCoded(varsIdx)=isHardCoded(varsIdxB);
end

assignin('base','VariableNamesList',VariableNamesList);
setappdata(fig,'VariableNamesList',VariableNamesList);
save(projectSettingsMATPath,'VariableNamesList','-append');