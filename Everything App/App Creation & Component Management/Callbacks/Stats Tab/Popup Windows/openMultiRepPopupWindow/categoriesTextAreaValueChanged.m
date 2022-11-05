function []=categoriesTextAreaValueChanged(src,event)

%% PURPOSE: SET THE CATEGORIES FOR THE CURRENT REPETITION MULTI VARIABLE
% Entries should be one per line. Leading & trailing spaces are removed.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value=handles.categoriesTextArea.Value;

if isscalar(value)
    disp('Why is there only one value here? Unnecessary if so! Aborting.');
    return;
end

valueTr=cellfun(@strtrim,value,'UniformOutput',false); % Remove white spaces.

for i=1:length(valueTr)
    if ~isvarname(valueTr{i})
        disp(['Line ' num2str(i) ' not a valid variable name! Fix before continuing']);
        return;
    end
end

setappdata(fig,'cats',valueTr);