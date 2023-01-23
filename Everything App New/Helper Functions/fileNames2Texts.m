function [texts]=fileNames2Texts(filenames)

%% PURPOSE: CONVERT FILE NAMES TO UITREENODE TEXT FORMAT

% filename format: {class}_{name}_ID_PSID.json
% text format: {name}_ID_PSID

texts=cell(size(filenames));
for i=1:length(filenames)
    name=filenames{i};

    % Remove extension if present
    extIdx=strfind(name,'.json');

    if ~isempty(extIdx)
        name=name(1:extIdx-1);
    end

    % Remove class name
    underscoreIdx=strfind(name,'_');

    name=name(underscoreIdx(1)+1:end);

    texts{i}=name;

end