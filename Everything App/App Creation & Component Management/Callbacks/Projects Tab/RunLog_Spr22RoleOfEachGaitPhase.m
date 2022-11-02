%% RUN LOG FOR PROJECT: Spr22RoleOfEachGaitPhase
% Initially Generated On: 05-Oct-2022 12:28:34

tic;
pgui(true); % Open the uifigure
projectName = 'Spr22RoleOfEachGaitPhase';
addProjectButtonPushed(gui, projectName);

% Update the code folder path for this project.
% 05-Oct-2022 12:28:34
codePath = 'C:\Users\Mitchell\Desktop\Matlab Code\GitRepos\Spr21-TWW-Biomechanics\';
codePathFieldValueChanged(gui, codePath);

% Changed tabs
% 05-Oct-2022 12:28:36
tabName = 'Projects';
tabGroup1SelectionChanged(gui, tabName);

% Update the code folder path for this project.
% 05-Oct-2022 13:40:04
codePath = 'C:\Users\Mitchell\Desktop\Matlab Code\GitRepos\Spr21-TWW-Biomechanics\';
codePathFieldValueChanged(gui, codePath);

setappdata(gui,'isRunLog',false);
toc;
