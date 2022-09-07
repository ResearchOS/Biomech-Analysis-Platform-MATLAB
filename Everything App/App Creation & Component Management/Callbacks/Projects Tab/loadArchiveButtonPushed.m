function []=loadArchiveButtonPushed(src)

%% PURPOSE: LOAD A PREVIOUSLY CREATED ARCHIVE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

codePath=getappdata(fig,'codePath');

archiveButtonPushed(fig); % First, archive the existing code.

[archiveFile,path]=uigetfile('*.zip','Select the archive to restore',[codePath 'Project Archives'],'MultiSelect','off');

if isequal(archiveFile,0) || isequal(path,0)
    disp('Process aborted, no archives loaded.');
    return;
end

fullPath=[path archiveFile];

destPath=[codePath 'Loaded Archive'];

if exist(destPath,'dir')~=7
    mkdir(destPath);
end

unzip(fullPath,destPath);

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

archiveFile=archiveFile(1:end-4);

loadedPath=[destPath slash archiveFile slash];

%% Restore files & folder to their usual places
folderNames={'Hard-Coded Variables','Processing Functions','SpecifyTrials'};
for i=1:length(folderNames)
%     rmdir([codePath folderNames{i}],'s'); % Do I need to delete the old folder first? Or does that not matter?
    copyfile([loadedPath folderNames{i}],[codePath folderNames{i}]);
end

listing=dir(loadedPath);
names={listing.name};
fileNames=names(~[listing.isdir]);
% Exclude the logsheet and logsheet MAT file paths
logsheetPath=getappdata(fig,'logsheetPath');
[path,name,ext]=fileparts(logsheetPath);
name=[name ext];
logsheetPathMAT=getappdata(fig,'logsheetPathMAT');
[pathMAT,nameMAT,ext]=fileparts(logsheetPathMAT);
nameMAT=[nameMAT ext];
fileNames=fileNames(~ismember(fileNames,{name,nameMAT}));
for i=1:length(fileNames)
    copyfile([loadedPath fileNames{i}],[codePath fileNames{i}]);
end

% Copy the logsheet MAT files back to their respective locations
copyfile([loadedPath slash name],logsheetPath);
copyfile([loadedPath slash nameMAT],logsheetPathMAT);

rmdir(loadedPath,'s');
rmdir(destPath);

disp(['Archive successfully loaded from: ' archiveFile '.zip']);