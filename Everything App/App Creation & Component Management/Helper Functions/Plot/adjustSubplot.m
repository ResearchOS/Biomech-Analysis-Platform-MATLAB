function []=adjustSubplot(src,event)

%% PURPOSE: CHANGE THE SUBPLOT POSITIONING OF THE CURRENT AXES OBJECT.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

axLetter=handles.Plot.currCompUITree.SelectedNodes.Text;

axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;

%% Prompt the user for where the plot should be located.
if ~isfield(Plotting.Plots.(plotName).Axes.(axLetter),'AxPos')
    Plotting.Plots.(plotName).Axes.(axLetter).AxPos='(1,1,1)';
end

axLoc=Plotting.Plots.(plotName).Axes.(axLetter).AxPos;

loc=inputdlg('Specify where to locate the axes as (m,n,p)','Subplot',1,{axLoc});

if isempty(loc) || isempty(loc{1})
    return;
end

loc=loc{1};

assert(isequal(loc([1 end]),'()'));

loc=loc(2:end-1);
loc=loc(~isspace(loc));
locSplit=strsplit(loc,',');

f=@(locSplit) isstrprop(locSplit,'digit');

tf=cellfun(f,locSplit,'UniformOutput',true);
try
    assert(all(tf) && length(tf)==3); % Make sure that all entries are numeric
catch
    disp('All entries must be numbers, separated by two commas');
    return;
end

subplot(str2double(locSplit{1}),str2double(locSplit{2}),str2double(locSplit{3}),axHandle);

Plotting.Plots.(plotName).Axes.(axLetter).AxPos=['(' loc ')'];

setappdata(fig,'Plotting',Plotting);