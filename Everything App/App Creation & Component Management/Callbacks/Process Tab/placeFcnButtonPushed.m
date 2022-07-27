function []=placeFcnButtonPushed(src,event)

%% PURPOSE: PLACE A FUNCTION FROM THE LIST OF FUNCTIONS IN THE PROCESSING FUNCTIONS FOLDER FOR THIS PROJECT INTO THE PROCESSING GUI FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the list of function names for this project
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fcnsDir=[getappdata(fig,'codePath') 'Processing Functions' slash];

listing=dir([fcnsDir '*.m']);
fcnNames={listing.name};
[~,idx]=sort(upper(fcnNames));
fcnNames=fcnNames(idx);

%% Have the user select the desired function.
% Also (in the future), add a text area for that function's description
% too.
label={'Select a function','Only one function can be placed at a time',};
[idx,tf]=listdlg('ListString',fcnNames,'PromptString',label,'SelectionMode','single','Name','Select function');

if ~tf
    return;
end

fcnName=fcnNames{idx};

%% Have the user select where to place the function on the plot
axes(handles.Process.mapFigure);
loc=ginput(1);