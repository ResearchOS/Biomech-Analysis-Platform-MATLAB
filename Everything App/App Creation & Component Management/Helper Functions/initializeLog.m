function []=initializeLog(src)

%% PURPOSE: INITIALIZE THE LOG OF ALL ACTIONS TAKEN FOR THE CURRENT PROJECT

fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

projectName=getappdata(fig,'projectName');

codePath=getappdata(fig,'codePath');

logPath=[codePath 'RunLog_' projectName '.m'];

setappdata(fig,'runLogPath',logPath);

if exist(logPath,'file')==2
    return;
end

text{1,1}=['%% RUN LOG FOR PROJECT: ' projectName];
currDate=char(datetime('now'));
text{2,1}=['% Initially Generated On: ' currDate];
text{3,1}='';
text{4,1}='pgui(true); % Open the uifigure';
text{5,1}=['projectName = ' '''' projectName ''';'];
text{6,1}=['addProjectButtonPushed(gui, projectName);'];
text{7,1}='';
text{8,1}='setappdata(gui,''isRunLog'',false);'; % Allow for user editing of the GUI again.
text{9,1}='';

fid=fopen(logPath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);