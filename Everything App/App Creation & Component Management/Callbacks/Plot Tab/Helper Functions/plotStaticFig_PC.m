function []=plotStaticFig_PC(fig,allTrialNames,records)

%% PURPOSE: CREATE PROJECT-LEVEL PLOT, WHERE THE DATA IS SPLIT BY CONDITION.

handles=getappdata(fig,'handles');

% Get the letters of each axes being plotted
Plotting=getappdata(fig,'Plotting');

selNode=handles.Plot.plotFcnUITree.SelectedNodes;
plotName=selNode.Text;

compNames=fieldnames(Plotting.Plots.(plotName));

compNames=compNames(~ismember(compNames,{'SpecifyTrials','Movie','ExTrial','Metadata'}));

axLetters=fieldnames(Plotting.Plots.(plotName).Axes);

Q=figure; % Create the figure
axTags=cell(size(axLetters));
for i=1:length(axLetters)
    axLoc=Plotting.Plots.(plotName).Axes.(axLetters{i}).AxPos;
    axHandles.(axLetters{i})=subplot(str2double(axLoc(2)),str2double(axLoc(4)),str2double(axLoc(6)));
    hold(axHandles.(axLetters{i}),'on');
    axTags{i}=['Axes ' axLetters{i}];
end

%% Go through each component to see which axes it is a child of
% NOTE: NEED TO MODIFY THE GRAPHICS OBJECT PROPERTIES HERE, INCLUDING AXES LIMITS.
for axNum=1:length(axLetters)

    axTag=axTags{axNum};

    % Set axes limits
    axLetter=axLetters{axNum};
    if isfield(Plotting.Plots.(plotName).Axes.(axLetter),'AxLims')
        axLims=Plotting.Plots.(plotName).Axes.(axLetter).AxLims;
        setAxLims(fig,axHandles.(axLetter),axLims,plotName,records.(axLetter),[]);
    end

    for i=1:length(compNames)

        compName=compNames{i};
        letters=fieldnames(Plotting.Plots.(plotName).(compName));

        setappdata(fig,'compName',compName);

        for j=1:length(letters)
            setappdata(fig,'letter',letters{j});
            if isequal(compName,'Axes')
                tag='';
                axLetter=axLetters{axNum};
            else
                tag=Plotting.Plots.(plotName).(compName).(letters{j}).Parent;  
                spaceIdx=strfind(tag,' ');
                axLetter=tag(spaceIdx+1:end);
            end
            allProps=Plotting.Plots.(plotName).(compName).(letters{j}).Properties;
            changedProps=Plotting.Plots.(plotName).(compName).(letters{j}).ChangedProperties;

            % Set the axes properties
            if isequal(compName,'Axes')
                h=axHandles.(axLetter);
                for k=1:length(changedProps)
                    currProps=changedProps{k};
                    for l=1:length(currProps)
                        currProp=currProps{l};
                        if ~all(ishandle(allProps.(currProp)))
                            h.(currProp)=allProps.(currProp);
                        else
                            h.(currProp)=copyobj(allProps.(currProp),h);
                        end
                    end
                end
                continue;
            end


            if ~isequal(tag,axTag)
                continue;
            end

            axHandle=axHandles.(axLetter);

            h=feval([compName '_PC'],axHandle,allTrialNames);

            for compNum=1:length(h)
                for k=1:length(changedProps)
                    currProps=changedProps{k};
                    for l=1:length(currProps)
                        currProp=currProps{l};
                        h(compNum).(currProp)=allProps.(currProp);
                    end
                end
            end

        end

    end

end

%% Save the figure to file
slash=filesep;
currDate=char(datetime('now'));
currDate=currDate(1:11);
plotFolder=[getappdata(fig,'dataPath') 'Plots' slash plotName slash currDate];
if ~isfolder(plotFolder)
    mkdir(plotFolder);
end
projectName=getappdata(fig,'projectName');
plotPath=[plotFolder slash plotName '_' projectName];

saveas(Q,[plotPath '.fig']);
saveas(Q,[plotPath '.svg']);
saveas(Q,[plotPath '.png']);

close(Q);