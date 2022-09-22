function []=createCompButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PLOTTING COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
Plotting=getappdata(fig,'Plotting');
if isempty(Plotting) || ~isfield(Plotting,'CompNames')
    allCompNames='';
else
    allCompNames=Plotting.Components.Names;
end

%% Ask the user for the component name
compNameOK=0;
while ~compNameOK
    compName=input('Enter component name: '); % Avoids the inputdlg
    
    if isempty(compName) || (iscell(compName) && isempty(compName{1}))
        disp('Process cancelled, no component added');
        return;
    end

    if iscell(compName)
        compName=compName{1};
    end

    compName=strtrim(compName);
    compName(isspace(compName))='_'; % Replace spaces with underscores

    if ~isvarname(compName)
        beep;
        disp('Try again, invalid component name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(compName)>namelengthmax
        beep;
        disp(['Try again, argument name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(compName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allCompNames,compName);
    if any(idx)
        disp('This component already exists! No components added, terminating the process.');
        return;
    end

    compNameOK=1;
end

%% Ask the user what kind of graphics object this is
types={'line','xyzline','scatter3','scatter','plot','plot3','image (Image Processing Toolbox needed)'};
type=listdlg('SelectionMode','single','PromptString','Select graphics object for this component','ListString',types);

if isempty(type)
    disp('Process aborted, no component added');
    return;
end

defVals=getProps(types{type});

%% Add the component name & default properties to the list of component names
if isempty(Plotting)  || ~isfield(Plotting,'Components') % The first component being added
    Plotting.Components.Names{1}=compName;
    Plotting.Components.DefaultProperties{1}=defVals;
else    
    Plotting.Components.Names=[Plotting.Components.Names; {compName}];
    Plotting.Components.DefaultProperties=[Plotting.Components.DefaultProperties; {defVals}];
    [~,idx]=sort(upper(Plotting.Components.Names));
    Plotting.Components.Names=Plotting.Components.Names(idx); % Keep the component names in alphabetical order
    Plotting.Components.DefaultProperties=Plotting.Components.DefaultProperties(idx);
end

makeCompNodes(fig,1:length(Plotting.Components.Names),Plotting.Components.Names)

%% Create & open the component .m file
codePath=getappdata(fig,'codePath');
plotFolder=[codePath 'Plot' slash 'Components'];
if exist(plotFolder,'dir')~=7
    mkdir(plotFolder);
end

compPath=[plotFolder slash compName '_P.m'];

% NEED TO CREATE THE TEMPLATE TO COPY FOR EACH COMPONENT (COULD ALSO JUST BE CELL ARRAY THAT I WRITE TO THE FILE)
text{1}=['function []=' compName '_P(subName,trialName,repNum)'];
text{2}='';
text{3}='subNames=allTrialNames.Subjects;';

if exist(compPath,'file')~=2
    fid=fopen(compPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
end
edit(compPath);

setappdata(fig,'Plotting',Plotting);