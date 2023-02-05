function [handles]=plotComponents(currFig,plotStructPS,subName,trialName,repNum)

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

% legend('AutoUpdate','off');

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
        piCompPath=getClassFilePath(piComp,'Component');
        piCompStruct=loadJSON(piCompPath);
        if exist(piCompStruct.MFileName,'file')~=2
            error(['File does not exist! ' piCompStruct.MFileName]);
        end
        psCompPath=getClassFilePath(axComps{j},'Component');
        psCompStruct=loadJSON(psCompPath);
        getRunInfo(piCompStruct,psCompStruct);
        axes(axHandle);
        hold on;
        handles.(axComps{j})=feval(piCompStruct.MFileName,subName,trialName,repNum);
    end

    % Set axes limits
    

end

% legend('AutoUpdate','on');

% Modify all component properties
if exist(plotStructPS.MFileName,'file')~=2
    error(['File does not exist! ' plotStructPS.Text]);
end
feval(plotStructPS.MFileName, currFig, handles, subName, trialName);