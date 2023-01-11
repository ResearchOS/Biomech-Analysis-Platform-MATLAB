function [filenames]=getClassFilenames(fig,class,root)

%% PURPOSE: RETURN ALL OF THE INSTANCES OF A CLASS IN THE CLASS FOLDER.
% Inputs:
% commonPath: the path containing all class folders (char)
% class: the class folder to look in (char)
% root: the root project-specific folder, for project-specific instances (char)

slash=filesep;

if nargin==2
    root=getCommonPath(fig);   
end

classFolder=[root slash class];

listing=dir(classFolder);
folders=[listing.isdir];
listing=listing(~folders);

names={listing.name};
exts=cell(size(names));

for i=1:length(names)
    prdIdx=strfind(names{i},'.');
    exts{i}=names{i}(prdIdx(end)+1:end);
end

% Because json are "ground truth". Maybe in the future there's a toggle for .mat or .json?
jsonIdx=ismember(exts,'json');

filenames=names(jsonIdx);