function []=runButtonPushed(src,event)

%% PURPOSE: RUN THE FUNCTIONS CURRENTLY SELECTED IN THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

disp('Running process queue');

queue=getCurrent('Process_Queue');

%% For now, just run everything. Later on, I can do checks to see if there are any dependencies that are not up to date.
[bool,logVar]=checkLogsheetSetup(fig);
if ~bool
    disp('Need to set up logsheet!');
    return;
end

% Make sure that a data path has been set up


try
    testGUI=evalin('base','gui;'); % Var isn't used, just checking if GUI var is in base workspace.
    clear testGUI;
catch
    assignin('base','gui',fig); % Ensure that the fig variable is available for use.
end

startAll=tic;
slash=filesep;
oldDir=cd([getCommonPath slash 'Code']); % Ensure that the proper functions are being called.
for i=1:length(queue)    

    uuid=queue{i};
    runProcess(uuid,true);           

end

cd(oldDir);

disp(['Finished running all functions in queue in ' num2str(round(toc(startAll),2)) ' seconds']);