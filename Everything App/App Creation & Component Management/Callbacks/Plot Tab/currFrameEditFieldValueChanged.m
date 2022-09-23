function []=currFrameEditFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE PLOT FOR THE CURRENT FRAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

value=handles.Plot.currFrameEditField.Value;

if value<handles.Plot.currFrameEditField.Value
    handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;
    return;
end

Plotting.Plots.(plotName).Movie.currFrame=value;

setappdata(fig,'Plotting',Plotting);

axLetters=fieldnames(Plotting.Plots.(plotName).Axes);
for axNum=1:length(axLetters)

    axLetter=axLetters{axNum};
    axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;
    childGroups={axHandle.Children.Tag};

    for compNum=1:length(childGroups)

        currName=childGroups{compNum};
        spaceIdx=strfind(currName,' ');
        compName=currName(1:spaceIdx-1);
        letter=currName(spaceIdx+1:end);

        refreshPlotComp(fig,[],plotName,compName,letter,axLetter)

    end

end

