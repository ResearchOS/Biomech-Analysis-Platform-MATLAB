function []=openMFilePlot(src,event)

%% PURPOSE: OPEN THE M FILE FOR COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Plot.allComponentsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;

compName=selNode.Text;

if isMovie==0
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text '_P.m'];
else
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text '_Movie.m'];
end

if exist(filePath,'file')==2
    edit(filePath);
else
    if isMovie==1
        text{1}=['function [h]=' compName '_Movie(ax,allVars,idx)'];
        text{2}='';
        text{3}='var1=allVars.var1;';
    else
        text{1}=['function [h]=' compName '_P(ax,subName,trialName,repNum)'];
        text{2}='';
        text{3}='subNames=allTrialNames.Subjects;';
    end    

    fid=fopen(filePath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
    edit(filePath);
end