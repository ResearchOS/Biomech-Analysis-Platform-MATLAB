function []=createStatsFcnButtonPushed(src,event)

%% PURPOSE: CREATE A NEW STATS FUNCTION IN THE LIST
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

% tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

if isempty(Stats) || ~isfield(Stats,'Functions')
    allFcnNames='';
else
    if isstruct(Stats.Functions)
        allFcnNames=fieldnames(Stats.Functions);
    else
        allFcnNames=Stats.Functions;
    end
end

okName=false;
while ~okName
    fcnName=inputdlg('Enter function name');
    
    if isempty(fcnName) || (iscell(fcnName) && isempty(fcnName{1}))
        disp('Process cancelled, no table added');
        return;
    end

    if iscell(fcnName)
        fcnName=fcnName{1};
    end

    fcnName=strtrim(fcnName);
    fcnName(isspace(fcnName))='_'; % Replace spaces with underscores

    if ~isvarname(fcnName)
        beep;
        disp('Try again, invalid function name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(fcnName)>namelengthmax
        beep;
        disp(['Try again, function name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(fcnName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allFcnNames,fcnName);
    if any(idx)
        disp('This function already exists! No function added, terminating the process.');
        return;
    end

    okName=true;
end

%% Add the function name to the Stats struct
if isstruct(Stats.Functions) && isempty(fieldnames(Stats.Functions))
    Stats.Functions={fcnName};
else
    Stats.Functions=[Stats.Functions; {fcnName}];
end
[~,sortIdx]=sort(upper(Stats.Functions));
Stats.Functions=Stats.Functions(sortIdx);

%% Update the GUI
makeStatsFcnNodes(fig,1:length(Stats.Functions),Stats.Functions);

%% Create the .m file
text{1}=['function [summ]=' fcnName '_Stats(projectStruct,subName,trialName,repNum)'];
text{2}='';
text{3}='%% PURPOSE: SUMMARIZE A VARIABLE';
text{4}='';

slash=filesep;
fileName=[getappdata(fig,'codePath') 'Statistics' slash fcnName '_Stats.m'];

if exist(fileName,'file')~=2 % Don't overwrite!
    fid=fopen(fileName,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
end

%% Set the Stats struct back to the fig
setappdata(fig,'Stats',Stats);