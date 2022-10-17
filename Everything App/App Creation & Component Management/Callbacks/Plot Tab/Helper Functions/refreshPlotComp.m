function []=refreshPlotComp(src,event,plotName,compName,letter,axLetter)

%% PURPOSE: REFRESH THE PLOTTED COMPONENT WITH NEW TRIAL/ATTRIBUTES
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

assignin('base','gui',fig);

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
end

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;
switch compName
    case 'Axes'
        h=findobj(handles.Plot.plotPanel,'Tag',['Axes ' letter]);
        if isempty(h)
            h=axes('Parent',handles.Plot.plotPanel,'Visible','on','Tag',['Axes ' letter]);
        end
        tempH=copyobj(h,fig);
        delete(h);
        h=axes('Parent',handles.Plot.plotPanel,'Visible','on','Tag',['Axes ' letter]);
        Plotting.Plots.(plotName).(compName).(letter).Handle=h;
        hold(h,'on');
        if isMovie==1
            axis(h,'equal');
        end
        axLetter=letter;
        if ~isfield(Plotting.Plots.(plotName).(compName).(letter),'ChangedProperties')
            Plotting.Plots.(plotName).(compName).(letter).ChangedProperties=cell(size(h));
        end
        propsChangedList=Plotting.Plots.(plotName).(compName).(letter).ChangedProperties;

        for i=1:length(propsChangedList)
            currProps=propsChangedList{i};
            for j=1:length(currProps)
                currProp=currProps{j};
                if ~isempty(currProp)
                    h.(currProp)=tempH.(currProp);
                end
            end
        end
        delete(tempH);
    otherwise
        if ~isfield(Plotting.Plots.(plotName),'SpecifyTrials')
            disp('Need to select a specify trials!');
            beep;
            return;
        end
        level=Plotting.Plots.(plotName).Metadata.Level;
        if ~isfield(Plotting.Plots.(plotName),'ExTrial') && ~ismember(level,{'P','PC'})
            beep;
            disp('Need to specify a trial!');
            return;
        end
        if ~ismember(level,{'P','PC'})
            plotExTrial=Plotting.Plots.(plotName).ExTrial;
            subName=plotExTrial.Subject;
        end
        setappdata(fig,'plotName',plotName);
        setappdata(fig,'compName',compName);
        setappdata(fig,'letter',letter);
        if exist('axLetter','var')~=1
            axLetter=compNode.Parent.Parent.Text;
        end
        axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;   
        hold(axHandle,'on');

        % 1. Get the hggroup that contains the current component.
        currGroupHandle=findobj(axHandle,'Type','hggroup','Tag',[compName ' ' letter]); % Uniquely identifies the current group
        if isempty(currGroupHandle)
            currGroupHandle=hggroup(axHandle,'Tag',[compName ' ' letter]);
        end

        tempGroupHandle=copyobj(currGroupHandle,axHandle); % Contains a copy of the objects, just to retain their properties
        tempH=tempGroupHandle.Children;
        delete(currGroupHandle.Children);

        if isMovie==0            
            switch level
                case 'P'
                    specifyTrialsName=Plotting.Plots.(plotName).SpecifyTrials;
                    inclStruct=feval(specifyTrialsName);
                    load(getappdata(fig,'logsheetPathMAT'),'logVar');
                    allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);
                    feval([compName '_P'],currGroupHandle,allTrialNames);
                case 'PC'
                    specifyTrialsName=Plotting.Plots.(plotName).SpecifyTrials;
                    inclStruct=feval(specifyTrialsName);
                    load(getappdata(fig,'logsheetPathMAT'),'logVar');
                    allTrialNames=getTrialNames(inclStruct,logVar,fig,1,[]);
                    feval([compName '_PC'],currGroupHandle,allTrialNames);
                case 'C'

                case 'S'

                case 'SC'

                case 'T'
                    trialName=plotExTrial.Trial;
                    repNum=1;
                    h=feval([compName '_T'],currGroupHandle,subName,trialName,repNum); 
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
%                     eval(['allData.var' num2str(i) '=' namesInCode{i} ';']);
                    allData.(['var' num2str(i)])=eval(namesInCode{i});
                end
            else
                allData.var1=getArg;
%                 namesInCodeOut='var1';
%                 eval([namesInCodeOut '=getArg;']);
            end
            
            idx=Plotting.Plots.(plotName).Movie.currFrame;
            h=feval([compName '_Movie'],axHandle,allData,idx);
        end  


%         currGroupHandle=findobj(axHandle,'Type','hggroup','Tag',[compName ' ' letter]);
%         if isempty(currGroupHandle)
%             currGroupHandle=hggroup(axHandle,'Tag',[compName ' ' letter]); % First time
%             Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
%             for i=1:length(h)
%                 h(i).Parent=currGroupHandle;
%             end
%         end        
%         tempGroupHandle=copyobj(currGroupHandle,axHandle);
%         delete(currGroupHandle.Children); % Get rid of the old components  

        if ~isfield(Plotting.Plots.(plotName).(compName).(letter),'ChangedProperties')
            Plotting.Plots.(plotName).(compName).(letter).ChangedProperties=cell(size(currGroupHandle.Children));
        end

        propsChangedList=Plotting.Plots.(plotName).(compName).(letter).ChangedProperties;        
        if ~isempty(propsChangedList)
            for i=1:length(tempH)
                if isempty(properties(tempH(i))) % There is no graphics object here
                    continue;
                end
%                 tempH(i).Parent=currGroupHandle;
                currChangedProperties=propsChangedList{i};
                if isempty(currGroupHandle.Children)
                    continue;
                end
                for j=1:length(currChangedProperties)
                    currProp=currChangedProperties{j};
                    currGroupHandle.Children(i).(currProp)=tempH(i).(currProp);
                end

            end
        end
        delete(tempGroupHandle);
        Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;

end

setappdata(fig,'Plotting',Plotting);
if isequal(compName,'Axes')
    adjustSubplot(fig,[],axLetter);
end
evalin('base','toc;');