function [piTexts]=getPITextFromPS(psTexts)

%% PURPOSE: IDENTIFY WHICH PROJECT-INDEPENDENT TEXTS THE SPECIFIED PROJECT-SPECIFIC TEXTS DERIVE FROM.
% Removes the project-specific ID

% project-specific texts format: {name}_ID_PSID
% project-independent texts format: {name}_ID

if ~iscell(psTexts)
    psTexts={psTexts};
end

piTexts=cell(size(psTexts));

for i=1:length(psTexts)

    currText=psTexts{i};

    underscoreIdx=strfind(currText,'_');

    piTexts{i}=currText(1:underscoreIdx(end)-1);

end