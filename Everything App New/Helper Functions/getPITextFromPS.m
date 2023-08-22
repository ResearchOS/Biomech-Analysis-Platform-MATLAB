function [piTexts]=getPITextFromPS(psTexts)

%% PURPOSE: IDENTIFY WHICH PROJECT-INDEPENDENT TEXTS THE SPECIFIED PROJECT-SPECIFIC TEXTS DERIVE FROM.
% Removes the project-specific ID

% project-specific texts format: {name}_ID_PSID
% project-independent texts format: {name}_ID

if isempty(psTexts)
    piTexts='';
    return;
end

if ~iscell(psTexts)
    psTexts={psTexts};
end

piTexts=cell(size(psTexts));

for i=1:length(psTexts)

    currText=psTexts{i};

    [name,id]=deText(currText);

    piTexts{i}=[name '_' id];

%     underscoreIdx=strfind(currText,'_');
% 
%     piTexts{i}=currText(1:underscoreIdx(end)-1);

end

if length(piTexts)==1
    piTexts=piTexts{1};
end