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
if (isequal(selNode.Parent,handles.Process.allVariablesUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
    isNew=true;
else
    isNew=false;
end

% PI node selected
if isequal(selNode.Parent,handles.Process.allVariablesUITree) && ~isNew
    if length(selNode.Children)==1
        selNode=selNode.Children(1);
    elseif length(selNode.Children)>1
        disp('Multiple options, please select a project-specific option!');
        expand(selNode);
        return;
    end
end

% Get the currently selected PS daughter struct (class Process or Component)
fullPath=getClassFilePath(motherNode.Text, daughterClass);
daughterStruct_PS=loadJSON(fullPath);

% Check if daughterNode already has a variable assigned that is being replaced. If so, need to unlink
% that variable from the mother class object
if contains(daughterNode.Text,' ')
    spaceIdx=strfind(daughterNode.Text,' ');
    varText=daughterNode.Text(spaceIdx+2:end-1);
    prevVarPath=getClassFilePath(varText, 'Variable');
    prevVarStruct=loadJSON(prevVarPath);
    [prevVarStruct, daughterStruct_PS]=unlinkClasses(prevVarStruct, daughterStruct_PS);
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

[name,id]=deText(selNode.Text);

% Get the PI variable struct.
piText=[name '_' id];
varPathPI=getClassFilePath(piText,'Variable');
varStructPI=loadJSON(varPathPI);

switch isNew
    case true
        % Create a new project-specific ID for the variable to add.
        varStruct=createVariableStruct_PS(varStructPI);
    case false
        varPath=getClassFilePath_PS(selNode.Text, 'Variable');
        varStruct=loadJSON(varPath);
end

% If the variable is hard-coded, indicate that this version did not come from any process function.
% Helpful because in the future I don't have to load the PI struct.
% Potentially tough to debug!!!!!!
if varStructPI.IsHardCoded
    varStruct.BackwardLinks_Process={'HardCoded'};
end

% Apply the currently selected variable to that arg.
if isequal(currTab,'Process')
    if isequal(parentText(1:6),'getArg')
        fldName='InputVariables';
        varStruct.ForwardLinks_Process=unique([varStruct.ForwardLinks_Process; {daughterStruct_PS.Text}]);
    elseif isequal(parentText(1:6),'setArg')
        fldName='OutputVariables';
        varStruct.BackwardLinks_Process=unique([varStruct.BackwardLinks_Process; {daughterStruct_PS.Text}]);
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
if ~varStructPI.IsHardCoded && isequal(fldName,'InputVariables')
    linkClasses(varStruct, daughterStruct_PS); % Input variables are "ForwardLinks" to the Process function.
elseif isequal(fldName,'OutputVariables')
    linkClasses(daughterStruct_PS,varStruct); % Output variables are "BackwardLinks" to the Process function.
else
    writeJSON(varPath, varStruct); % Just save the changes.
end

% Modify/add nodes
argTextSplit=strsplit(daughterNode.Text,' ');
argText=[argTextSplit{1} ' (' varStruct.Text ')'];
daughterNode.Text=argText;

if isNew
    uitreenode(selNode,'Text',varStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end