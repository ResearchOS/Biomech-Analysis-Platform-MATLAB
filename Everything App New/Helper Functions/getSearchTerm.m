function [searchTerm]=getSearchTerm(searchbox)

%% PURPOSE: GET THE SEARCH TERM, IGNORING THE WORD "SEARCH"

searchTerm=searchbox.Value;

if isequal(searchTerm,'Search')
    searchTerm='';
end