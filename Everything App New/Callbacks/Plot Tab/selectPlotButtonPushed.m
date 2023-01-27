function []=selectPlotButtonPushed(src,event)

%% PURPOSE: SELECT THE CURRENTLY SELECTED PLOT. IF PI, CREATE NEW PS PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

plotNode=handles.Plot.allPlotsUITree.SelectedNodes;

if isempty(plotNode)
    return;
end 

projectPath=getProjectPath(fig);
if isempty(projectPath)
    return;
end

projectSettingsFile=getProjectSettingsFile(fig);
projectSettings=loadJSON(projectSettingsFile);

% Create new PS process group struct if PI node is selected
if isequal(plotNode.Parent,handles.Plot.allPlotsUITree)
    fullPath=getClassFilePath(plotNode);
    piStruct=loadJSON(fullPath);
    psStruct=createPlotStruct_PS(fig,piStruct);
    Current_Plot_Name=psStruct.Text;
    uitreenode(plotNode,'Text',psStruct.Text); % Create new PS node.
else % Use pre-existing PS node.
    Current_Plot_Name=plotNode.Text;
end

%% Create project-specific plot file if one does not exist.
projectSettings.Current_Plot_Name=Current_Plot_Name;
writeJSON(projectSettingsFile,projectSettings);

handles.Plot.currentPlotLabel.Text=Current_Plot_Name;

fillPlotUITree(fig);

plotPath=getClassFilePath(Current_Plot_Name,'Plot',fig);
plotStructPS=loadJSON(plotPath);
specifyTrials=plotStructPS.SpecifyTrials;
specifyTrialsUITree=handles.Plot.allSpecifyTrialsUITree;

checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree);