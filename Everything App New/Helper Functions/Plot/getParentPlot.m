function [linkedPlots]=getParentPlot(psText)

%% PURPOSE: RETURN THE PARENT PLOT OF THE SPECIFIED COMPONENT

psPath=getClassFilePath(psText,'Component');
psStruct=loadJSON(psPath);

%% If the specified component is an axes
if contains(psStruct.Text,'Axes_000000')
    linkedPlots={};
    if isfield(psStruct,'ForwardLinks_Plot')
        linkedPlots=psStruct.ForwardLinks_Plot;
    end
    return;
end

%% If the specified component is anything else.
axes={};
if isfield(psStruct,'ForwardLinks_Component')
    axes=psStruct.ForwardLinks_Component;
end

linkedPlots={};

for i=1:length(axes)

    axPath=getClassFilePath(axes{i},'Component');
    axStruct=loadJSON(axPath);

    linkedPlots=[linkedPlots; axStruct.ForwardLinks_Plot'];

end