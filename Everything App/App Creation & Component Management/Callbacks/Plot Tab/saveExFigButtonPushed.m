function []=saveExFigButtonPushed(src,event)

%% PURPOSE: SAVE THE CURRENT STATE OF THE EXAMPLE FIGURE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

dataPath=getappdata(fig,'dataPath');

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

exTrial=Plotting.Plots.(plotName).ExTrial;
trialName=exTrial.Trial;
subName=exTrial.Subject;

slash=filesep;

currDate=char(datetime('now'));
currDate=currDate(1:11); % Date only
savePlotFolder=[dataPath 'Plots' slash plotName slash 'Example Plots' slash currDate];
if ~isfolder(savePlotFolder)
    mkdir(savePlotFolder);
end

savePlotPath=[savePlotFolder slash trialName '_' subName '_' projectName];

Q=figure('Visible','off');
a=axes(Q);
parent=hggroup;
children=handles.Plot.plotPanel.Children;

saveas(Q,[savePlotPath '.fig']);
saveas(Q,[savePlotPath '.svg']);
saveas(Q,[savePlotPath '.png']);

close(Q);