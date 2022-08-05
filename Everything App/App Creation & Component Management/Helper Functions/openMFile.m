function []=openMFile(src,currPoint)

%% PURPOSE: OPEN THE .M FILE FOR THE SELECTED FUNCTION
% Inputs:
% src: Graphics object of the pgui (graphics object)
% currPoint: The current place in the processing map figure that the person
% double clicked (1 x 2 double)

fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

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