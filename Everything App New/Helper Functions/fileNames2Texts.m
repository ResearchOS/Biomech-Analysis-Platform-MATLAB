function [texts]=fileNames2Texts(filenames)

%% PURPOSE: CONVERT FILE NAMES TO UITREENODE TEXT FORMAT

% filename format: AABBBBBB_CCC.json
% text format: AABBBBBB_CCC

isChar=false;
if ischar(filenames)
    filenames={filenames};
    isChar=true;
end

texts=cell(size(filenames));
for i=1:length(filenames)
    name=filenames{i};

    % Remove extension if present
    extIdx=strfind(name,'.json');

    if ~isempty(extIdx)
        name=name(1:extIdx-1);
    end

    texts{i}=name;

end

if isChar
    texts=texts{1};
end