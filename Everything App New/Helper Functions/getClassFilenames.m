function [filenames]=getClassFilenames(class,isInstance)

%% PURPOSE: RETURN ALL OF THE INSTANCES OF A CLASS IN THE CLASS FOLDER.
% Inputs:
% class: The class to look for in the folder
% isInstance: Whether to look in the "Instances" folder (true) or not (false)

slash=filesep;

if nargin==1
    isInstance=false;
end

if ~isInstance    
    root=getCommonPath();   
    classFolder = [root slash class];
else
    classFolder=[getCommonPath slash class slash 'Instances'];
end

listing=dir(classFolder);
folders=[listing.isdir];
listing=listing(~folders);

names={listing.name};
exts=cell(size(names));

for i=1:length(names)
    prdIdx=strfind(names{i},'.');
    exts{i}=names{i}(prdIdx(end)+1:end);
end

jsonIdx=ismember(exts,'json');

filenames=names(jsonIdx);