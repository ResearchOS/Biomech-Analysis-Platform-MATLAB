function []=addFuncRunCode(fcnName,fcnSplit,inputVarNames,inputVarNamesInCode,outputVarNames,outputVarNamesInCode,nodeNumber,specifyTrials,runOrder,prevFcnNodeNumber,isImport,coordinate)

%% PURPOSE: FROM THE RUN CODE, ADD A FUNCTION (& VARIABLES) TO THE SETTINGS VARIABLES.
% Each input variable corresponds to one column of the Digraph Nodes table.

try
    VariableNamesList=evalin('base','VariableNamesList;');
catch
    disp('VaribleNamesList missing from base workspace!');
    return;
end

try
    Digraph=evalin('base','Digraph;');
catch
    disp('Digraph missing from base workspace!');
    return;
end

% try
%     NonFcnSettingsStruct=evalin('base','NonFcnSettingsStruct');
% catch
%     disp('NonFcnSettingsStruct missing from base workspace!');
%     return;
% end
    
%% Add the function to the Digraph. If the node number already exists, modify that row instead of creating a new one at the end.
if ~ismember(nodeNumber,Digraph.Nodes.NodeNumber) % Add a new node
    digraphNodeVarNames=Digraph.Nodes.Properties.VariableNames;
    cellVar=cell(1,size(Digraph.Nodes,2));
    cellVar{1}=fcnName;
    cellVar{2}=''; % Fcn description
    cellVar{3}=struct(fcnSplit,inputVarNames);
    cellVar{4}=struct(fcnSplit,outputVarNames);
    cellVar{5}=coordinate;
    cellVar{6}=nodeNumber;
    cellVar{7}=specifyTrials;
    cellVar{8}=isImport;
    cellVar{9}=struct(fcnSplit,inputVarNamesInCode);
    cellVar{10}=struct(fcnSplit,outputVarNamesInCode);
    cellVar{11}=struct(fcnSplit,runOrder);
    Digraph=addnode(Digraph,cell2table(cellVar),'VariableNames',digraphNodeVarNames);  
    rowIdx=length(Digraph.Nodes.NodeNumber);
else
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
if ~ismember([prevFcnNodeNumber nodeNumber],Digraph.Edges.NodeNumber,'rows') % Skip adding an edge if the edge has already been added
    digraphEdgeVarNames=Digraph.Edges.Properties.VariableNames;    
    cellVar=cell(1,size(Digraph.Edges,2));
    cellVar{1}=[prevRowIdx rowIdx];
    cellVar{2}=[Digraph.Nodes.FunctionNames{prevRowIdx} Digraph.Nodes.FunctionNames{rowIdx}];
    cellVar{3}=[Digraph.Nodes.NodeNumber{prevRowIdx} Digraph.Nodes.NodeNumber{rowIdx}];
    underscoreIdx=strfind(fcnSplit,'_');
    splitCode=fcnSplit(underscoreIdx+1:end);
    cellVar{5}=splitCode;
    splitRows=find(ismember(Digraph.Edges.SplitCode,splitCode)==1);
    cellVar{4}=Digraph.Edges.Color{splitRows(1)};
    Digraph=addedge(Digraph,cell2table(cellVar),'VariableNames',digraphEdgeVarNames);
end

assignin('base','Digraph',Digraph);

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

if any(~ismember(inputVarNamesVarList,guiNames)) % At least one of the input variables are new.
    newVarIdx=~ismember(inputVarNamesVarList,guiNames); % The idx of the new variables.
    newVarNames=[newVarNames; inputVarNamesVarList(newVarIdx)]; 
    newSaveVarNames=[newSaveVarNames; inputVarNamesSaveNames(newVarIdx)];
end

if any(~ismember(outputVarNamesVarList,guiNames))
    newVarIdx=~ismember(outputVarNamesVarList,guiNames); % The idx of the new variables.
    newVarNames=[newVarNames; outputVarNamesVarList(newVarIdx)]; 
    newSaveVarNames=[newSaveVarNames; outputVarNamesSaveNames(newVarIdx)];
end

% Add the variable GUI names
VariableNamesList.GUINames=[VariableNamesList.GUINames; newVarNames];

% Add the variable names in code
VariableNamesList.SaveNames=[VariableNamesList.SaveNames; newSaveVarNames];

% Add the split names & codes
for i=1:length(newVarNames)
    spaceIdx=strfind(newVarNames{i},' ');
    splitName=newVarNames{i}(1:spaceIdx-1);
    splitCode=newVarNames{i}(spaceIdx+2:end-1);
    varRow=ismember(VariableNamesList.GUINames,newVarNames{i});
    VariableNamesList.SplitNames{varRow}=splitName;
    VariableNamesList.SplitCodes{varRow}=splitCode;
    VariableNamesList.Descriptions{varRow}='Enter Arg Description Here';
    VariableNamesList.Level{varRow}='T'; % Default to trial level variable. This currently doesn't have any real importance, so this is ok
    VariableNamesList.IsHardCoded{varRow}=0; % Default to not hard coded. This will need to be changed in the settings var (& the var to be created) as needed.
end

assignin('base','VariableNamesList',VariableNamesList);
