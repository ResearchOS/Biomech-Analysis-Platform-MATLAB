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
types={'line','xyzline','scatter3','scatter','plot','plot3','image (Image Processing Toolbox needed)','quiver','quiver3'};
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
% codePath=getappdata(fig,'codePath');
% plotFolder=[codePath 'Plot' slash 'Components'];
% if exist(plotFolder,'dir')~=7
%     mkdir(plotFolder);
% end
% 
% compPathStatic=[plotFolder slash compName '_P.m']; % Static plot file
% compPathMovie=[plotFolder slash compName '_Movie.m']; % Movie plot file (has different arguments
% 
% % NEED TO CREATE THE TEMPLATE TO COPY FOR EACH COMPONENT (COULD ALSO JUST BE CELL ARRAY THAT I WRITE TO THE FILE)
% textStatic{1}=['function [h]=' compName '_P(ax,subName,trialName,repNum)'];
% textStatic{2}='';
% textStatic{3}='subNames=allTrialNames.Subjects;';
% 
% if exist(compPathStatic,'file')~=2
%     fid=fopen(compPathStatic,'w');
%     fprintf(fid,'%s\n',textStatic{1:end-1});
%     fprintf(fid,'%s',textStatic{end});
%     fclose(fid);
% end
% 
% textMovie{1}=['function [h]=' compName '_Movie(ax,allVars,idx)'];
% textMovie{2}='';
% textMovie{3}='var1=allVars.var1;';
% 
% if exist(compPathMovie,'file')~=2
%     fid=fopen(compPathMovie,'w');
%     fprintf(fid,'%s\n',textMovie{1:end-1});
%     fprintf(fid,'%s',textMovie{end});
%     fclose(fid);
% end
% 
% plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;
% isMovie=Plotting.Plots.(plotName).Movie.IsMovie;
% 
% if isMovie==0
%     edit(compPathStatic);
% else
%     edit(compPathMovie);
% end

setappdata(fig,'Plotting',Plotting);