function []=refreshPlotComp(src,event,plotName,compName,letter)

%% PURPOSE: REFRESH THE PLOTTED COMPONENT WITH NEW TRIAL/ATTRIBUTES
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('plotName','var')~=1
    plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;
    if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
        disp('Select a plot first!');
        return;
    end
end

Plotting=getappdata(fig,'Plotting');

compNames=fieldnames(Plotting.Plots.(plotName));
compNames=compNames(~ismember(compNames,{'SpecifyTrials','ExTrial'}));

compNode=handles.Plot.currCompUITree.SelectedNodes;
if isempty(compNode)
    return;
end
letter=compNode.Text;

if ismember(letter,compNames)
    disp('Must select a letter!');
    return;
end

compName=compNode.Parent.Text;

switch compName
    case 'Axes'
        h=axes('Parent',handles.Plot.plotPanel,'Visible','on');
        Plotting.Plots.(plotName).(compName).(letter).Handle=h;
    otherwise
        plotExTrial=Plotting.Plots.(plotName).ExTrial;
        subName=plotExTrial.Subject;
        trialName=plotExTrial.Trial;
        repNum=1;
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
        currGroupHandle=Plotting.Plots.(plotName).(compName).(letter).Handle;        
        Q=figure('Visible','off');
        Qax=axes(Q);      
        feval([compName '_P'],subName,trialName,repNum);
        delete(currGroupHandle.Children); % Get rid of the old components
        set(Qax.Children,'Parent',currGroupHandle); % Add the new components

end