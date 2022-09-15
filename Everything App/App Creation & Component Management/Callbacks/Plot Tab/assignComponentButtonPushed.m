function []=assignComponentButtonPushed(src,event)

%% PURPOSE: ASSIGN THE CURRENTLY SELECTED GRAPHICS OBJECT TO THE CURRENTLY SELECTED FUNCTION VERSION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(Plotting)
    disp('No plotting info added!');
    return;
end

if isempty(handles.Plot.allComponentsUITree.SelectedNodes)
    disp('Need to select a component!');
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    disp('Need to select a plot!');
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

compName=handles.Plot.allComponentsUITree.SelectedNodes.Text;

compNames=fieldnames(Plotting.Plots.(plotName));

if ~ismember(compName,compNames)
    newLetters='A';    
else
    letters=fieldnames(Plotting.Plots.(plotName).(compName)); % Should be in alphabetical order.
    maxLetters=letters{end}; % Check if all letters are Z. If so, prepend an 'A', and set all letters to 'A'.
    newLetters=maxLetters;
    if isequal(maxLetters,repmat('Z',1,length(maxLetters)))
        newLetters=repmat('A',1,length(maxLetters)+1);
    else
        nonZidx=find(ismember(maxLetters,'Z')~=1,1,'last'); % Get the index of the singular letter to increment.
        zIdxToTheRight=1:length(maxLetters)>nonZidx; % Get the index of the Z's to set to A's
        newLetters(nonZidx)=char(double(maxLetters(nonZidx)+1)); % Increment the letter
        newLetters(zIdxToTheRight)=repmat('A',1,sum(zIdxToTheRight)); % Replace the Z's to the right of the incremented letter with A's
    end
end

Plotting.Plots.(plotName).(compName).(newLetters).Variables=struct(); % Initialize this component in this plot's metadata
compIdx=ismember(Plotting.Components.Names,compName);
Plotting.Plots.(plotName).(compName).(newLetters).Properties=Plotting.Components.DefaultProperties{compIdx};

if isequal(compName,'Axes')
    h=axes(handles.Plot.Tab,'OuterPosition',[0.5 0.07 0.5 0.87],'InnerPosition',[0.52 0.12 0.47 0.8],'Visible','on');
else
    h=createUIComp(fig,plotName,compName,newLetters);
end

Plotting.Plots.(plotName).(compName).(newLetters).Handle=h;

%% Make the component appear in the current components UI tree
makeCurrCompNodes(fig,Plotting.Plots.(plotName))

setappdata(fig,'Plotting',Plotting);