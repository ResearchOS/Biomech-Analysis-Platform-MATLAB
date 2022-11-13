function []=refreshPlotComp(src,event,plotName,compName,letter,axLetter,prevObj,newObj)

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

setappdata(fig,'tabName','Plot');

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;
plotLevel=Plotting.Plots.(plotName).Metadata.Level;
load(getappdata(fig,'logsheetPathMAT'),'logVar');
switch compName
    case 'Axes'
        h=findobj(handles.Plot.plotPanel,'Tag',['Axes ' letter]);
        view=h.View;
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
        allProps=Plotting.Plots.(plotName).(compName).(axLetter).Properties;
        for i=1:length(propsChangedList)
            currProps=propsChangedList{i};
            for j=1:length(currProps)
                currProp=currProps{j};
                if ~isempty(currProp)
                    h.(currProp)=tempH.(currProp);
                    allProps.(currProp)=h.(currProp);
                end
            end
        end
        Plotting.Plots.(plotName).(compName).(axLetter).Properties=allProps;
        delete(tempH);

        % Set axes limits.
        if isMovie==0
            if isfield(Plotting.Plots.(plotName).(compName).(axLetter),'AxLims')
                axLims=Plotting.Plots.(plotName).(compName).(axLetter).AxLims;
                axHandle=Plotting.Plots.(plotName).(compName).(axLetter).Handle;
                specifyTrials=Plotting.Plots.(plotName).SpecifyTrials;
                inclStruct=feval(specifyTrials);
                allTrialNamesC=getTrialNames(inclStruct,logVar,fig,1,[]);
                allTrialNamesNC=getTrialNames(inclStruct,logVar,fig,0,[]);
                for dim='XYZ'
                    varNames=axLims.(dim).SaveNames;
                    subvars=axLims.(dim).SubvarNames;
                    value=axLims.(dim).VariableValue;
                    if iscell(value)
                        value=value{1};
                    end
                    isHardCoded=axLims.(dim).IsHardCoded;
                    if contains(axLims.(dim).Level,'C')
                        allTrialNames=allTrialNamesC;
                    else
                        allTrialNames=allTrialNamesNC;
                    end
                    
                    if ~isempty(varNames)
                        if ~isHardCoded
                            records.(dim)=getPlotAxesLims(fig,allTrialNames,varNames,subvars);
                        else
                            records.(dim)=eval(value);
                            records.(dim)=records.(dim)(2)-records.(dim)(1);
                        end
                    else
                        records.(dim)=NaN;
                    end
                end
                if isequal(plotLevel,'T')
                    plotExTrial=Plotting.Plots.(plotName).ExTrial;
                else
                    plotExTrial=[];
                end
                setAxLims(fig,axHandle,axLims,plotName,records,plotExTrial);
            end
        elseif isMovie==1
            if isfield(Plotting.Plots.(plotName).(compName).(axLetter),'AxLims')
                axLims=Plotting.Plots.(plotName).(compName).(axLetter).AxLims;
                axHandle=Plotting.Plots.(plotName).(compName).(axLetter).Handle;
                axHandle.Clipping='off';
                specifyTrials=Plotting.Plots.(plotName).SpecifyTrials;
                inclStruct=feval(specifyTrials);
                allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);
                currIdx=Plotting.Plots.(plotName).Movie.currFrame;
                dimNum=0;
                axis(axHandle,'equal');
                for dim='XYZ'
                    varNames=axLims.(dim).SaveNames;
                    subvars=axLims.(dim).SubvarNames;
                    value=axLims.(dim).VariableValue;
                    if iscell(value)
                        value=value{1};
                    end
                    isHardCoded=axLims.(dim).IsHardCoded;
                    relativeView=axLims.(dim).RelativeView;
                    % Get the data for the center of the figure that was stored to the pgui
                    dimNum=dimNum+1;
                    centerData(1,dimNum)=Plotting.Plots.(plotName).Axes.(axLetter).MovieAxLimsVar.(dim)(currIdx,dimNum);
                    offset=abs(eval(Plotting.Plots.(plotName).Axes.(axLetter).AxLims.(dim).VariableValue{1})); % Always positive.
                    relativeView=Plotting.Plots.(plotName).Axes.(axLetter).AxLims.(dim).RelativeView;
                    if length(offset)==1
                        offset=[-1*offset offset];
                    end
                    if relativeView==1
                        axLims.(dim)=offset+centerData(1,dimNum); % Min & max axes limits.
                    else
                        axLims.(dim)=centerData(1,dimNum);
                    end
                    axHandle.([dim 'Lim'])=axLims.(dim);
                end
                axHandle.View=view;
            end
        end
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

        Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
        delete([currGroupHandle.Children]);

        if isMovie==0
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
            specifyTrialsName=Plotting.Plots.(plotName).SpecifyTrials;
            inclStruct=feval(specifyTrialsName);
            allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);
            trialName=plotExTrial.Trial;
            repNum=allTrialNames.(subName).(trialName);
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
                    allData.(['var' num2str(i)])=eval(namesInCode{i});
                end
            else
                allData.var1=getArg;
            end

            idx=Plotting.Plots.(plotName).Movie.currFrame;
            h=feval([compName '_Movie'],axHandle,allData,idx);

        end

        % Assign components to group
        for i=1:length(h)
            if ~isequal(class(h(i)),'matlab.graphics.GraphicsPlaceholder')
                h(i).Parent=currGroupHandle;
            end
        end

        % This needs to be here so that every element of the group can have its own changed properties (allow for multi-type groups)
        if ~isfield(Plotting.Plots.(plotName).(compName).(letter),'ChangedProperties') || ~isequal(size(Plotting.Plots.(plotName).(compName).(letter).ChangedProperties),size(currGroupHandle.Children))
            Plotting.Plots.(plotName).(compName).(letter).ChangedProperties=cell(size(currGroupHandle.Children));
        end

        propsChangedList=Plotting.Plots.(plotName).(compName).(letter).ChangedProperties;
        allProps=Plotting.Plots.(plotName).(compName).(letter).Properties;
        if ~isempty(propsChangedList)
            for i=1:length(currGroupHandle.Children)
                if isempty(properties(currGroupHandle.Children(i))) % There is no graphics object here
                    continue;
                end
                currChangedProperties=propsChangedList{i};
                if isempty(currGroupHandle.Children) % There are no graphics objects in this group
                    continue;
                end
                for j=1:length(currChangedProperties)
                    currProp=currChangedProperties{j};
                    currGroupHandle.Children(i).(currProp)=allProps.(currProp); % Set the property
                end

            end
        end

        Plotting.Plots.(plotName).(compName).(letter).Handle=currGroupHandle;
        Plotting.Plots.(plotName).(compName).(letter).Properties=allProps;

end

setappdata(fig,'Plotting',Plotting);
if isequal(compName,'Axes')
    adjustSubplot(fig,[],axLetter);
end
evalin('base','toc;');