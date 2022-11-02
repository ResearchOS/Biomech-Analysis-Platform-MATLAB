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
    h=axes(handles.Plot.plotPanel,'Visible','on','Tag',['Axes ' newLetters]);
    Plotting.Plots.(plotName).(compName).(newLetters).Handle=h;
    props=properties(h);
    for i=1:length(props)
        defProps.(props{i})=h.(props{i});
    end
    Plotting.Plots.(plotName).(compName).(newLetters).Properties=defProps;
    Plotting.Plots.(plotName).Axes.(newLetters).AxPos='(1,1,1)';
else
    currSelNode=handles.Plot.currCompUITree.SelectedNodes;
    if isempty(currSelNode)
        disp('Must have axes letter selected in current components UI tree!');
        return;
    end
    currSelNodeParent=currSelNode.Parent;
    props=properties(currSelNodeParent);
    if ~ismember('Text',props) || ~isequal(currSelNodeParent.Text,'Axes')
        disp('Must have axes letter selected in current components UI tree!');
        return;
    end
    axLetter=currSelNode.Text;
    h=hggroup(Plotting.Plots.(plotName).Axes.(axLetter).Handle);
    Plotting.Plots.(plotName).(compName).(newLetters).Handle=h;
    Plotting.Plots.(plotName).(compName).(newLetters).Parent=['Axes ' axLetter];
%     idx=ismember(Plotting.Components.Names,compName);
%     Plotting.Plots.(plotName).(compName).(newLetters).Properties=struct();
end

%% Make the component appear in the current components UI tree
makeCurrCompNodes(fig,Plotting.Plots.(plotName),compName,newLetters)

setappdata(fig,'Plotting',Plotting);