function []=runButtonPushed(src,event)

%% PURPOSE: RUN THE FUNCTIONS CURRENTLY SELECTED IN THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile(fig);
projectSettings=loadJSON(projectSettingsFile);

queue=projectSettings.ProcessQueue;

%% For now, just run everything. Later on, I can do checks to see if there are any dependencies that are not up to date.
[bool,logVar]=checkLogsheetSetup(fig);
if ~bool
    return;
end

% Make sure that a data path has been set up


try
    testGUI=evalin('base','gui;'); % Var isn't used, just checking if GUI var is in base workspace.
catch
    assignin('base','gui',fig); % Ensure that the fig variable is available for use.
end

startAll=tic;
for i=1:length(queue)    

    text=queue{i};
    runProcess(text,true);           

end

disp(['Finished running all functions in queue in ' num2str(round(toc(startAll),2)) ' seconds']);