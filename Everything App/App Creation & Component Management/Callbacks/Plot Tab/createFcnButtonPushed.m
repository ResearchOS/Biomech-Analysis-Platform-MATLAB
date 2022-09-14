function []=createFcnButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PLOT (WHICH IS AN ASSOCIATION OF GRAPHICS OBJECTS)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

Plotting=getappdata(fig,'Plotting');

if isempty(Plotting) || ~isfield(Plotting,'Plots')
    allPlotNames='';
else
    allPlotNames=fieldnames(Plotting.Plots);
end

%% Ask the user for the plot name
plotNameOK=0;
while ~plotNameOK
    plotName=input('Enter plot name: '); % Avoids the inputdlg
    
    if isempty(plotName) || (iscell(plotName) && isempty(plotName{1}))
        disp('Process cancelled, no plot added');
        return;
    end

    if iscell(plotName)
        plotName=plotName{1};
    end

    plotName=strtrim(plotName);
    plotName(isspace(plotName))='_'; % Replace spaces with underscores

    if ~isvarname(plotName)
        beep;
        disp('Try again, invalid plot name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(plotName)>namelengthmax
        beep;
        disp(['Try again, plot name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(plotName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allPlotNames,plotName);
    if any(idx)
        disp('This plot already exists! No plots added, terminating the process.');
        return;
    end

    plotNameOK=1;
end

%% Add the plot name to the list of plot names
Plotting.Plots.(plotName)=struct();

plotNames=fieldnames(Plotting.Plots);
[~,idx]=sort(upper(plotNames));
plotNames=plotNames(idx);
vals=repmat({''},1,length(plotNames));
args=[plotNames';vals];
orderedStruct=struct(args{:});

Plotting.Plots=orderfields(Plotting.Plots,orderedStruct);
plotNames=fieldnames(Plotting.Plots);

makePlotNodes(fig,1:length(plotNames),plotNames);

setappdata(fig,'Plotting',Plotting);