function [handles]=plotComponents(fig,currFig,plotStructPS,subName,trialName)

%% PURPOSE: GIVEN A FIGURE HANDLE AND THE PROJECT-SPECIFIC PLOTTING STRUCT, PLOT THE COMPONENTS USING USER-DEFINED M FILES.

if exist('subName','var')~=1
    subName='';
end

if exist('trialName','var')~=1
    trialName='';
end

axesList=plotStructPS.BackwardLinks_Component;

for i=1:length(axesList)
    ax=axesList{i};
    axHandle=axes(currFig);
    handles.(ax)=axHandle;
    fullPath=getClassFilePath(ax, 'Component', fig);
    axStruct=loadJSON(fullPath);
    % Reposition the axes        

    axComps=axStruct.BackwardLinks_Component;
    for j=1:length(axComps)
        handles.(axComps{j})=feval(axComps{j},axHandle,subName,trialName);
    end

    % Set axes limits

    % How to change other axes properties? Unclear!

end

% Modify all component properties