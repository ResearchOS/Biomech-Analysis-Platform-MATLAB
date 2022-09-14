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
    allCompNames=Plotting.CompNames;
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

%% Add the component name to the list of component names
if isempty(Plotting)  || ~isfield(Plotting,'CompNames') % The first component being added
    Plotting.CompNames{1}=compName;
else    
    Plotting.CompNames=[Plotting.CompNames; {compName}];
    [~,idx]=sort(upper(Plotting.CompNames));
    Plotting.CompNames=Plotting.CompNames(idx); % Keep the component names in alphabetical order
end

makeCompNodes(fig,1:length(Plotting.CompNames),Plotting.CompNames)

%% Create & open the component .m file
codePath=getappdata(fig,'codePath');
plotFolder=[codePath 'Plot' slash 'Components'];
if exist(plotFolder,'dir')~=7
    mkdir(plotFolder);
end

compPath=[plotFolder slash compName '.m'];

% NEED TO CREATE THE TEMPLATE TO COPY FOR EACH COMPONENT (COULD ALSO JUST BE CELL ARRAY THAT I WRITE TO THE FILE)
% copyfile(compTemplatePath,compPath); 
% edit(compPath);

setappdata(fig,'Plotting',Plotting);