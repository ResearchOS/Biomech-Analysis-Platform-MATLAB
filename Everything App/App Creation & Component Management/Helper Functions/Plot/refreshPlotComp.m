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
        hold(h,'on');
        axis(h,'equal');
    otherwise
        plotExTrial=Plotting.Plots.(plotName).ExTrial;
        subName=plotExTrial.Subject;
        trialName=plotExTrial.Trial;
        repNum=1;
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
        if exist('axLetter','var')~=1
            axLetter=compNode.Parent.Parent.Text;
        end
        axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;
        currGroupHandle=findobj(axHandle,'Type','hggroup','Tag',[compName ' ' letter]);
        if isempty(currGroupHandle)
            currGroupHandle=hggroup(axHandle,'Tag',[compName ' ' letter]); % First time
            Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
        end               
%         Q=figure('Visible','off');
%         Qax=axes(Q);
%         hold(Qax,'on');
        delete(currGroupHandle.Children); % Get rid of the old components

        isMovie=Plotting.Plots.(plotName).Movie.IsMovie;

        if isMovie==0
            h=feval([compName '_P'],axHandle,subName,trialName,repNum);               
        else
            namesInCode=Plotting.Plots.(plotName).(compName).(letter).Variables.NamesInCode;
            namesInCodeChar='{';
            for i=1:length(namesInCode)
                namesInCodeChar=[namesInCodeChar '''' namesInCode{i} '''' ','];
            end
            namesInCodeChar=[namesInCodeChar(1:end-1) '}'];
            namesInCodeOut=namesInCodeChar(2:end-1);
            namesInCodeOut=['[' namesInCodeOut ']'];
            namesInCodeOut=strrep(namesInCodeOut,'''',''); % Remove apostrophes

            eval([namesInCodeOut '=getArg(' namesInCodeChar ',subName,trialName,repNum);']);

            for i=1:length(namesInCode)
                eval(['allData.var' num2str(i) '=' namesInCode{i} ';']);
            end
            idx=Plotting.Plots.(plotName).Movie.currFrame;
            h=feval([compName '_Movie'],axHandle,allData,idx);
        end      
        drawnow;
        for i=1:length(h)
            if ~isempty(properties(h(i)))
                h(i).Parent=currGroupHandle;
            end
        end        

end

setappdata(fig,'Plotting',Plotting);
evalin('base','toc;');