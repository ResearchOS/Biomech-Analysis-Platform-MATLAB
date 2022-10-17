function []=adjustSubplot(src,event,axLetter)

%% PURPOSE: CHANGE THE SUBPLOT POSITIONING OF THE CURRENT AXES OBJECT.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

if exist('axLetter','var')~=1
    axLetter=handles.Plot.currCompUITree.SelectedNodes.Text;
end

axHandle=Plotting.Plots.(plotName).Axes.(axLetter).Handle;

%% Prompt the user for where the plot should be located.
if ~isfield(Plotting.Plots.(plotName).Axes.(axLetter),'AxPos')
    Plotting.Plots.(plotName).Axes.(axLetter).AxPos='(1,1,1)';
end

axLoc=Plotting.Plots.(plotName).Axes.(axLetter).AxPos;

if nargin<3 % When changing the subplots
    loc=inputdlg('Specify where to locate the axes as (m,n,p)','Subplot',1,{axLoc});
else % When just refreshing the subplots
    loc={axLoc};
end

if isempty(loc) || isempty(loc{1})
    return;
end

loc=loc{1};

assert(isequal(loc([1 end]),'()'));

loc=loc(2:end-1);
loc=loc(~isspace(loc));
locSplit=strsplit(loc,',');

f=@(locSplit) isstrprop(locSplit,'digit');
tf=cellfun(f,locSplit,'UniformOutput',false);

try
    assert(length(tf)==3);
catch
    disp('All three entries must be separated by a comma');
    return;
end

% Check that all entries are numbers, especially checking for decimals here.
for i=1:length(tf)

    fIdx=tf{i}==0;
    try
        assert(all(ismember(locSplit{i}(fIdx),'.')));
    catch
        disp('All entries must be numbers');
        return;
    end
        
end

% if ~isequal(mod(str2double(locSplit{3}),1),0)
%     disp('3rd entry must be an integer!');
%     return;
% end

subplot(str2double(locSplit{1}),str2double(locSplit{2}),str2double(locSplit{3}),axHandle);

Plotting.Plots.(plotName).Axes.(axLetter).AxPos=['(' loc ')'];

setappdata(fig,'Plotting',Plotting);