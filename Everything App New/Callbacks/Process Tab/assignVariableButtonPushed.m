function []=assignVariableButtonPushed(src,event)

%% PURPOSE: ASSIGN VARIABLE TO CURRENT PROCESSING FUNCTION

% motherNode is the "grouping" class object, and daughterNode is the
% "grouped" class object.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Tabs.tabGroup1.SelectedTab.Title;

switch currTab
    case 'Process'
        motherUITree=handles.Process.groupUITree;
        daughterUITree=handles.Process.functionUITree;    
        daughterClass='Process';
        motherClass='ProcessGroup';
    case 'Plot'
        motherUITree=handles.Plot.plotUITree;
        daughterUITree=handles.Plot.componentUITree;
        daughterClass='Component';
        motherClass='Plot';
    case 'Stats'

end

% All variables UI tree
selNode=handles.Process.allVariablesUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Current group UI tree
motherNode=motherUITree.SelectedNodes;

if isempty(motherNode)
    return;
end

% Current function UI tree
daughterNode=daughterUITree.SelectedNodes;

if isempty(daughterNode)
    return;
end

if isequal(daughterNode.Parent,daughterUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

% Determine whether to create a new project-specific variable version or
% use an existing one.
if isequal(selNode.Parent,handles.Process.allVariablesUITree)
    isNew=true;
else
    isNew=false;
end

% Get the currently selected PS daughter struct
fullPath=getClassFilePath_PS(motherNode.Text, daughterClass, fig);
daughterStruct_PS=loadJSON(fullPath);

% Check if daughterNode already has a variable assigned. If so, need to unlink
% that variable from the mother class object
if contains(daughterNode.Text,' ')
    spaceIdx=strfind(daughterNode.Text,' ');
    varText=daughterNode.Text(spaceIdx+2:end-1);
    prevVarPath=getClassFilePath(varText, 'Variable', fig);
    prevVarStruct=loadJSON(prevVarPath);
    [prevVarStruct, daughterStruct_PS]=unlinkClasses(fig, prevVarStruct, daughterStruct_PS);
end

% Get the ID number for which getArg/setArg is currently being modified.
parentNode=daughterNode.Parent;
parentText=parentNode.Text;
spaceSplit=strsplit(parentText,' ');
number=str2double(spaceSplit{2});

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[daughterUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=parentNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), parentNode)==1);

% Get the index of the arg being modified in that getArg/setArg
% instance.
idxNum=find(ismember(parentNode.Children,daughterNode)==1);

switch isNew
    case true
        % Create a new project-specific ID for the variable to add.
        varPath=getClassFilePath(selNode);
        varStructPI=loadJSON(varPath);
        varStruct=createVariableStruct_PS(fig,varStructPI);
    case false
        varPath=getClassFilePath_PS(selNode.Text, 'Variable', fig);
        varStruct=loadJSON(varPath);
end

% Apply the currently selected variable to that arg.
if isequal(currTab,'Process')
    if isequal(parentText(1:6),'getArg')
        fldName='InputVariables';
        varStruct.InputToProcess=unique([varStruct.InputToProcess; {daughterStruct_PS.Text}]);
    elseif isequal(parentText(1:6),'setArg')
        fldName='OutputVariables';
        varStruct.OutputOfProcess=unique([varStruct.OutputOfProcess; {daughterStruct_PS.Text}]);
    end
else
    fldName='InputVariables';
end

if ~iscell(daughterStruct_PS.(fldName)) || ...
        (iscell(daughterStruct_PS.(fldName)) && (length(daughterStruct_PS.(fldName))<argIdxNum || isempty(daughterStruct_PS.(fldName){argIdxNum})))
    daughterStruct_PS.(fldName){argIdxNum}{1}=number;
end

% Check that I'm putting things in the right place
assert(isequal(daughterStruct_PS.(fldName){argIdxNum}{1},number));

daughterStruct_PS.(fldName){argIdxNum}{idxNum+1}=varStruct.Text;

% Saves changes.
linkClasses(fig, varStruct, daughterStruct_PS); % Create a connection between the variable & the process function

% Modify/add nodes
argTextSplit=strsplit(daughterNode.Text,' ');
argText=[argTextSplit{1} ' (' varStruct.Text ')'];
daughterNode.Text=argText;

if isNew
    uitreenode(selNode,'Text',varStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end