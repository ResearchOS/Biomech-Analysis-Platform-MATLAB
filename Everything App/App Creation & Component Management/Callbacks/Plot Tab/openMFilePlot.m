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

level=Plotting.Plots.(plotName).Metadata.Level;

suffix=['_' level];

if isMovie==0
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text suffix '.m'];
else
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text suffix '_Movie.m'];
end

if exist(filePath,'file')==2
    edit(filePath);
else
    if isMovie==0
        createPlotFcn(filePath,level,compName);
        return;
    end

    % Initialize movie function
    text{1}=['function [h]=' compName '_Movie(ax,allVars,idx)'];
    text{2}='';
    text{3}='var1=allVars.var1;';

    fid=fopen(filePath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
    edit(filePath);


end