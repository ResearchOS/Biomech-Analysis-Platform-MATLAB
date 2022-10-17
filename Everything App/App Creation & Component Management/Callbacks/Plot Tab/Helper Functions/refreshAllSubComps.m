function []=refreshAllSubComps(src,event,selNode)

%% PURPOSE: REFRESH ALL SUBCOMPONENTS FOR ONE FIGURE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('selNode','var')~=1
    selNode=handles.Plot.currCompUITree.SelectedNodes;
end

if isempty(selNode)
    return;
end

plotNode=handles.Plot.plotFcnUITree.SelectedNodes;

if isempty(plotNode)
    return;
end

plotName=plotNode.Text;

Plotting=getappdata(fig,'Plotting');

currCompName=selNode.Text;

compLetters=fieldnames(Plotting.Plots.(plotName).(currCompName));

allComps=fieldnames(Plotting.Plots.(plotName));

allComps=allComps(~ismember(allComps,{'Movie','Axes','SpecifyTrials','ExTrial','Metadata'}));

%% Get the list of all components to update.
compList={};
for i=1:length(compLetters)
    letter=compLetters{i};    
    compList=[compList; {[currCompName ' ' letter ' ' letter]}];

    if ~isequal(currCompName,'Axes')  
        axTag=Plotting.Plots.(plotName).(currCompName).(letter).Parent;
        spaceIdx=strfind(axTag,' ');
        axLetter=axTag(spaceIdx+1:end);
        compList{end}=[currCompName ' ' letter ' ' axLetter];
        continue; % Because this only refreshes the selected component, no children components here.        
    end

    for j=1:length(allComps)
        compName=allComps{j};

        compLettersNew=fieldnames(Plotting.Plots.(plotName).(compName));

        for k=1:length(compLettersNew)
            currLetter=compLettersNew{k};
            if isequal(Plotting.Plots.(plotName).(compName).(currLetter).Parent,['Axes ' letter])
                compList=[compList; {[compName ' ' currLetter ' ' letter]}]; % Component name, component letter, axes letter
            end
        end

    end

end

if isequal(currCompName,'Axes') % Refreshing the entire figure
    delete(handles.Plot.plotPanel.Children);
end

%% Update all components one at a time
for i=1:length(compList)
    spaceIdx=strfind(compList{i},' ');
    compName=compList{i}(1:spaceIdx(1)-1);
    letter=compList{i}(spaceIdx(1)+1:spaceIdx(2)-1);
    axLetter=compList{i}(spaceIdx(2)+1:end);
    refreshPlotComp(fig,[],plotName,compName,letter,axLetter)
%     adjustSubplot(fig,[],subplotIdx);
end