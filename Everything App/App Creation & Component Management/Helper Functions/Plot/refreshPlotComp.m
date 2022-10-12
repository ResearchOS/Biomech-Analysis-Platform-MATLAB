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
compNames=compNames(~ismember(compNames,{'SpecifyTrials','ExTrial','Movie','Metadata'}));

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
end % Used for refreshing the subplots
%     axNodes=handles.Plot.currCompUITree.Children.Children;
%     compNode=axNodes(ismember(axNodes,findobj(handles.Plot.currCompUITree,'Text',axLetter)));
% end

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;
switch compName
    case 'Axes'
        h=findobj(handles.Plot.plotPanel,'Tag',['Axes ' letter]);
        delete(h);
        h=axes('Parent',handles.Plot.plotPanel,'Visible','on','Tag',['Axes ' letter]);
        Plotting.Plots.(plotName).(compName).(letter).Handle=h;
        hold(h,'on');
        if isMovie==1
            axis(h,'equal');
        end
        axLetter=letter;
    otherwise
        if ~isfield(Plotting.Plots.(plotName),'ExTrial')
            beep;
            disp('Need to specify a trial!');
            return;
        end
        plotExTrial=Plotting.Plots.(plotName).ExTrial;
        subName=plotExTrial.Subject;                
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
        if exist('axLetter','var')~=1
            axLetter=compNode.Parent.Parent.Text;
        end
        axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;   
        hold(axHandle,'on');

        if isMovie==0
            level=Plotting.Plots.(plotName).Metadata.Level;
            switch level
                case 'P'
                    specifyTrialsName=Plotting.Plots.(plotName).SpecifyTrials;
                    inclStruct=feval(specifyTrialsName);
                    load(getappdata(fig,'logsheetPathMAT'),'logVar');
                    allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);
                    h=feval([compName '_P'],axHandle,allTrialNames);
                case 'PC'
                    specifyTrialsName=Plotting.Plots.(plotName).SpecifyTrials;
                    inclStruct=feval(specifyTrialsName);
                    load(getappdata(fig,'logsheetPathMAT'),'logVar');
                    allTrialNames=getTrialNames(inclStruct,logVar,fig,1,[]);
                    h=feval([compName '_PC'],axHandle,allTrialNames);
                case 'C'

                case 'S'

                case 'SC'

                case 'T'
                    trialName=plotExTrial.Trial;
                    repNum=1;
                    h=feval([compName '_T'],axHandle,subName,trialName,repNum); 
            end
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

            if ~isempty(namesInCode)
                eval([namesInCodeOut '=getArg(' namesInCodeChar ',subName,trialName,repNum);']);
                for i=1:length(namesInCode)
                    eval(['allData.var' num2str(i) '=' namesInCode{i} ';']);
                end
            else
                allData.var1=getArg;
%                 namesInCodeOut='var1';
%                 eval([namesInCodeOut '=getArg;']);
            end
            
            idx=Plotting.Plots.(plotName).Movie.currFrame;
            h=feval([compName '_Movie'],axHandle,allData,idx);
        end      
        currGroupHandle=findobj(axHandle,'Type','hggroup','Tag',[compName ' ' letter]);
        if isempty(currGroupHandle)
            currGroupHandle=hggroup(axHandle,'Tag',[compName ' ' letter]); % First time
            Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
        end               
        delete(currGroupHandle.Children); % Get rid of the old components  
        for i=1:length(h)
            if ~isempty(properties(h(i))) % There is a graphics object here
                h(i).Parent=currGroupHandle;
            end
        end        
        Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;

end

setappdata(fig,'Plotting',Plotting);
if isequal(compName,'Axes')
    adjustSubplot(fig,[],axLetter);
end
evalin('base','toc;');