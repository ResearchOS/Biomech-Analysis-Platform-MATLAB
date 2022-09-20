function []=refreshPlotComp(src,event,plotName)

%% PURPOSE: REFRESH THE PLOTTED COMPONENT WITH NEW TRIAL/ATTRIBUTES
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% slash=filesep;

if exist('plotName','var')~=1
    plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;
    if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
        disp('Select a plot first!');
        return;
    end
else
    allAxes=findobj(handles.Plot.currCompUITree,'Text','Axes');
    allAxes=allAxes.Children; % The letters of each axes
    for i=1:length(allAxes)
        handles.Plot.currCompUITree.SelectedNodes=allAxes(i);
        refreshPlotComp(src);
    end    
    return;
end

Plotting=getappdata(fig,'Plotting');

codePath=getappdata(fig,'codePath');

compNames=fieldnames(Plotting.Plots.(plotName));
compNames=compNames(~ismember(compNames,{'SpecifyTrials','ExTrial'}));

compNode=handles.Plot.currCompUITree.SelectedNodes;
letter=compNode.Text;

if ismember(letter,compNames)
    disp('Must select a letter!');
    return;
end

compName=compNode.Parent.Text;

h=Plotting.Plots.(plotName).(compName).(letter).Handle;

switch compName
    case 'Axes'
        set(h,'Parent',handles.Plot.plotPanel,'Visible','on');
    otherwise
        plotExTrial=Plotting.Plots.(plotName).ExTrial;
        subName=plotExTrial.Subject;
        trialName=plotExTrial.Trial;
        repNum=1;
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
%         axLetter=compNode.Parent.Parent.Text;
%         axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;
        currGroupHandle=Plotting.Plots.(plotName).(compName).(letter).Handle;        
        Q=figure('Visible','off');
        Qax=axes(Q);
%         Qhg=hggroup(Qax);        
        feval(compName,subName,trialName,repNum);
        delete(currGroupHandle.Children); % Get rid of the old components
        set(Qax.Children,'Parent',currGroupHandle); % Add the new components

end