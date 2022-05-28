function []=addProjectButtonPushed(src)

fig=ancestor(src,'figure','toplevel');

projectName=inputdlg('Enter the new project name','New Project Name');

if isempty(projectName) || isempty(projectName{1})
    return; % Pressed Cancel, or did not enter anything.
end

projectName=projectName{1};

setappdata(fig,'projectName',projectName);

text=readAllProjects(getappdata(fig,'everythingPath'));
projectList=getAllProjectNames(text);

h=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
if ismember(projectName,projectList)
    disp(['Switching to existing project: ' projectName]);
    h.Value=projectName;
    switchProjectsDropDownValueChanged(fig);
    return;
end

if ~ismember(projectName,projectList)
    if ~isempty(projectList)
        h.Items=[projectList projectName];
    else
        h.Items={projectName};
    end
end
h.Items=h.Items(~ismember(h.Items,'New Project'));
h.Items=sort(h.Items);
h.Value=projectName;

setappdata(fig,'allProjectsList',h.Items); % Modify the internal list of project names

%% Add the project name to the bottom of the text file.
% numLines=length(text);
% recProjNamePrefix='Most Recent Project Name:';
% if ~isempty(text)
%     for i=numLines:-1:1
%         if isequal(text{i}(1:length(recProjNamePrefix)),recProjNamePrefix)
%             lastLine=i-2;
%             break;
%         end
%     end
%     
%     newText(1:lastLine)=text(1:lastLine);
%     newText{lastLine+1}='';
% else
%     lastLine=-1;
% end
% newText{lastLine+2}=['Project Name: ' projectName];
% newText{lastLine+3}='';
% newText{lastLine+4}=[recProjNamePrefix ' ' projectName];
% 
% fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
% fprintf(fid,'%s\n',newText{1:end-1});
% fprintf(fid,'%s',newText{end});
% fclose(fid);

%% Add the project name to the specify trials file (should not already be present).
specTrialsTxtFile="C:\Users\Mitchell\Desktop\Matlab Code\GitRepos\Biomech-Analysis-Platform\Everything App\App Creation & Component Management\allProjects_SpecifyTrials.txt";
text=regexp(fileread(specTrialsTxtFile),'\n','split');

text=[text {''} {['Project Name: ' projectName]}]; % Add the project name.
fid=fopen(specTrialsTxtFile,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid); % Close the file

switchProjectsDropDownValueChanged(fig);