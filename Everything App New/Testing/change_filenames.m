root = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath';
change_names(root);

function []=change_names(root)
listing = dir(root);
names = {listing.name};
dirIdx = [listing.isdir];

objTypes = {'Variable','SpecifyTrials','Process','ProcessGroup','Logsheet','Project','Analysis','Component','Plot'};

for i=1:length(names)
    name=names{i};
    if name(1)=='.'
        continue; % Remove . and .. and hidden folders
    end
    if dirIdx(i)
        change_names([listing(i).folder filesep name]);
        continue;
    end   

%     if contains(name,'__')
%         prevPath = [listing(i).folder filesep name '.json']; 
%         name = strrep(name,'__','_');        
%         newPath = [listing(i).folder filesep name '.json']; 
%         movefile(prevPath,newPath);
%         continue;
%     end

    if isequal(name(end-4:end),'.json')    
        name=name(1:end-5); % Remove the ".json"
    else
        continue;
    end

    % Check if this file name has already been changed to the new format.
    firstUnderscoreIdx = strfind(name,'_');
    if isempty(firstUnderscoreIdx)
        continue;
    end
    firstUnderscoreIdx = firstUnderscoreIdx(1);
    if ~ismember(name(1:firstUnderscoreIdx-1),objTypes)
        continue; % Skip previously changed filenames.
    end

    prevPath = [listing(i).folder filesep name '.json'];    
    
    class = name(1:firstUnderscoreIdx-1);
    if ismember(class,objTypes)
        % Convert previous format to new format
%         abbrev = className2Abbrev(class);

        underscoreIdx = strfind(name,'_');
        underscoreIdx = underscoreIdx(end);

        if length(name)-underscoreIdx==3
            instanceID=name(end-2:end);
            abstractID=name(end-9:end-4);
            name=name(firstUnderscoreIdx+1:end-11);
        else
            abstractID=name(end-5:end);
            instanceID='';
            name=name(firstUnderscoreIdx+1:end-7);
        end
        uuid = genUUID(class,abstractID,instanceID,name);
    end

    newPath = [listing(i).folder filesep uuid '.json'];
    movefile(prevPath,newPath);

end

end