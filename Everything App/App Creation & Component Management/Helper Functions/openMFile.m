function []=openMFile(src,currPoint,isIn)

%% PURPOSE: OPEN THE .M FILE FOR THE SELECTED FUNCTION
% Inputs:
% src: Graphics object of the pgui (graphics object)
% currPoint: The current place in the processing map figure that the person
% double clicked (1 x 2 double)
% isIn: 1 if opening a function, 0 if opening a variable .m file

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isIn==0
    if ispc==1
        slash='\';
    elseif ismac==1
        slash='/';
    end
    if isempty(handles.Process.splitsUITree.SelectedNodes) || isempty(handles.Process.fcnArgsUITree.SelectedNodes)
        return;
    end
    varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;
    splitName=handles.Process.splitsUITree.SelectedNodes.Text;
    load(getappdata(fig,'projectSettingsMATPath'),'NonFcnSettingsStruct');
    splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;
    isHC=handles.Process.convertVarHardDynamicButton.Value;
    fileName=[getappdata(fig,'codePath') 'Hard-Coded Variables' slash varName '_' splitCode '.m'];
    if isHC==1 && exist(fileName,'file')==2
        edit(fileName);
        return;
    end
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

digraphCoords=Digraph.Nodes.Coordinates;
allDists=sqrt((digraphCoords(:,1)-repmat(currPoint(1),length(digraphCoords),1)).^2+(digraphCoords(:,2)-repmat(currPoint(2),length(digraphCoords),1)).^2);
[~,idx]=min(allDists);

fcnName=Digraph.Nodes.FunctionNames{idx};

if isequal(fcnName,'Logsheet')
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fullPath=[getappdata(fig,'codePath') 'Processing Functions' slash fcnName '.m'];

oldPath=cd(getappdata(fig,'codePath'));
open(fullPath); % Give whole path?
cd(oldPath);