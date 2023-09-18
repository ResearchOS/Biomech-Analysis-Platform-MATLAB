function []=runButtonPushed(src,event)

%% PURPOSE: RUN THE FUNCTIONS CURRENTLY SELECTED IN THE QUEUE

headless = true;
if nargin>1
    headless = false;
    fig=ancestor(src,'figure','toplevel');
    handles=getappdata(fig,'handles');
end
stop = false;
e = '';

disp('Running process queue');

queue=getCurrent('Process_Queue');
if isempty(queue)
    disp('Nothing in queue!');
    return;
end
if ~iscell(queue)
    queue = {queue};
end

%% For now, just run everything. Later on, I can do checks to see if there are any dependencies that are not up to date.
% [bool,logVar]=checkLogsheetSetup(fig);
% if ~bool
%     disp('Need to set up logsheet!');
%     return;
% end

% Make sure that a data path has been set up

% try
%     testGUI=evalin('base','gui;'); % Var isn't used, just checking if GUI var is in base workspace.
%     clear testGUI;
% catch
%     assignin('base','gui',fig); % Ensure that the fig variable is available for use.
% end

startAll=tic;
% oldDir=cd([getCommonPath filesep 'Code']); % Ensure that the proper functions are being called.
for i=1:length(queue)    

    uuid=queue{i};
    [stop, message, subjectError, e] = runProcess(uuid,true);  
    if stop
        break;
    end

end

% cd(oldDir);

if ~headless
    sendEmail = handles.Process.sendEmailsCheckbox.Value;
else
    sendEmail = false; % Hard-coded for now.
end
elapsedTime = round(toc(startAll),2);

if ~stop
    disp(['Finished running all functions in queue in ' num2str(elapsedTime) ' seconds']);
    if sendEmail
        subjectSuccess = 'Successfully ran all functions';
        messageSuccess = ['Nice job. Finished in ' num2str(elapsedTime) ' seconds'];
        sendEmails(subjectSuccess, messageSuccess);
    end
else
    disp(['Aborted running on function ' getName(uuid)]);
    if sendEmail
        sendEmails(subjectError, message);
    end
end

if ~isempty(e)
    throw(e);
%     error(e);
end