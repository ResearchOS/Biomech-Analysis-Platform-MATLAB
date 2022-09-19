function []=unassignComponentButtonPushed(src,event)

%% REMOVE THE CURRENTLY SELECTED COMPONENT FROM THE CURRENTLY SELECTED FUNCTION VERSION
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(Plotting)
    disp('No plotting info added!');
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    disp('Need to select a plot!');
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

compNames=fieldnames(Plotting.Plots.(plotName));

% compName=handles.Plot.allComponentsUITree.SelectedNodes.Text;

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    disp('Need to select a current component!')
    return;
end

currNode=handles.Plot.currCompUITree.SelectedNodes;
currLetter=currNode.Text;

if ismember(currLetter,compNames)
    disp('Need to select a letter, not a component name!');
    return;
end

if ~isequal(class(currNode.Parent),'matlab.ui.container.TreeNode')
    disp('Need to select a letter, not the component itself!');
    return;
end

compName=currNode.Parent.Text;

if ~isfield(Plotting.Plots.(plotName),compName)
    makeCurrCompNodes(fig,Plotting.Plots.(plotName),compName,currLetter);
    return;
end

h=Plotting.Plots.(plotName).(compName).(currLetter).Handle; % Handle to the component's hggroup
if isvalid(h)
    delete(h); % Delete the graphics object.
end
Plotting.Plots.(plotName).(compName)=rmfield(Plotting.Plots.(plotName).(compName),currLetter);

if isempty(fieldnames(Plotting.Plots.(plotName).(compName)))
    Plotting.Plots.(plotName)=rmfield(Plotting.Plots.(plotName),compName); % If no more of this component in the current plot, remove it entirely.
end

if isequal(compName,'Axes')
    compNames=fieldnames(Plotting.Plots.(plotName));
    for i=1:length(compNames)
        compName=compNames{i};
        if isequal(compName,'Axes')
            continue;
        end
        letters=fieldnames(Plotting.Plots.(plotName).(compName));
        for j=1:length(letters)
            letter=letters{j};
            if isequal(Plotting.Plots.(plotName).(compName).(letter).Parent,['Axes ' currLetter])
                Plotting.Plots.(plotName).(compName)=rmfield(Plotting.Plots.(plotName).(compName),letter);
                if isempty(fieldnames(Plotting.Plots.(plotName).(compName)))
                    Plotting.Plots.(plotName)=rmfield(Plotting.Plots.(plotName),compName); % If no more of this component in the current plot, remove it entirely.
                end
            end
        end
    end
end

makeCurrCompNodes(fig,Plotting.Plots.(plotName),compName,currLetter);

setappdata(fig,'Plotting',Plotting);