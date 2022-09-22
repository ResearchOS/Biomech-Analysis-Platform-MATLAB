function []=refreshPlotComp(src,event,plotName,compName,letter,axLetter)

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

if exist('letter','var')~=1
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
end

% if exist('compName','var')~=1
%     compName=compNode.Parent.Text;
% end

switch compName
    case 'Axes'
        h=findobj(handles.Plot.plotPanel,'Tag',['Axes ' letter]);
        delete(h);
        h=axes('Parent',handles.Plot.plotPanel,'Visible','on','Tag',['Axes ' letter]);
        Plotting.Plots.(plotName).(compName).(letter).Handle=h;
    otherwise
        plotExTrial=Plotting.Plots.(plotName).ExTrial;
        subName=plotExTrial.Subject;
        trialName=plotExTrial.Trial;
        repNum=1;
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
%         Q=fig;
%         Qax=axes(Q,'Visible','off');
        if exist('axLetter','var')~=1
            axLetter=compNode.Parent.Parent.Text;
        end
        axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;
%         delete(axHandle.Children(~cellfun(@isempty,{axHandle.Children.Tag}))); % Unclear why these random groups show up, but delete them
        currGroupHandle=findobj(axHandle,'Type','hggroup','Tag',[compName ' ' letter]);
        if isempty(currGroupHandle)
            currGroupHandle=hggroup(axHandle,'Tag',[compName ' ' letter]); % First time
            Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
        end               
        Q=figure('Visible','off');
        Qax=axes(Q);
%         delete(currGroupHandle.Children);
%         axes(axHandle);     
%         set(fig,'CurrentObject',axHandle);
        delete(currGroupHandle.Children); % Get rid of the old components
        feval([compName '_P'],subName,trialName,repNum);               
        set(Qax.Children,'Parent',currGroupHandle); % Add the new components
        close(Q);
end

setappdata(fig,'Plotting',Plotting);