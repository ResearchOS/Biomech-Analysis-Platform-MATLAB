function []=saveCurrentFigure(fig,plotStructPS)

%% PURPOSE: SAVE THE CURRENT FIGURE

slash=filesep;

currDate=char(datetime('now'));

projectPath=getProjectPath();

plotName=plotStructPS.Text;

plotsFolder=[projectPath slash 'Plots'];

plotFolder=[plotsFolder slash plotName ' ' currDate(1:11)];

warning('off','MATLAB:MKDIR:DirectoryExists');
mkdir(plotFolder);
warning('on','MATLAB:MKDIR:DirectoryExists');

plotName=fig.Name;

fileName=[plotFolder slash plotName];

saveas(fig,[fileName '.fig']);
saveas(fig,[fileName '.svg']);
saveas(fig,[fileName '.png']);

close(fig);