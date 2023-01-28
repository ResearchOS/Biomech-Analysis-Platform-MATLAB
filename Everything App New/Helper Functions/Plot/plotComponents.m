function [handles]=plotComponents(currFig,plotStructPS,subName,trialName)

%% PURPOSE: GIVEN A FIGURE HANDLE AND THE PROJECT-SPECIFIC PLOTTING STRUCT, PLOT THE COMPONENTS USING USER-DEFINED M FILES.
% Plots static plots, NOT movies.

figure(currFig); % Focus the current figure.

if exist('subName','var')~=1
    subName='';
end

if exist('trialName','var')~=1
    trialName='';
end

axesList=plotStructPS.BackwardLinks_Component;

for i=1:length(axesList)
    ax=axesList{i};        
    fullPath=getClassFilePath(ax, 'Component');
    axStruct=loadJSON(fullPath);

    % Reposition the axes so things can be seen when plotting.
    pos=axStruct.Position;
    if length(pos)==4
        axHandle=subplot('Position',pos);
    elseif length(pos)==3
        axHandle=subplot(pos(1),pos(2),pos(3));
    else
        error([ax ' position improperly specified']);
    end
    handles.(ax)=axHandle;    

    if ~isfield(axStruct,'BackwardLinks_Component')
        continue;
    end

    axComps=axStruct.BackwardLinks_Component;
    for j=1:length(axComps)
        piComp=getPITextFromPS(axComps{j});
        handles.(axComps{j})=feval(piComp,axHandle,subName,trialName);
    end

    % Set axes limits
    

end

% Modify all component properties
feval([plotStructPS.Text],currFig, handles, subName, trialName);