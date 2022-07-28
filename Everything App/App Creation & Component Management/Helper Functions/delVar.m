function []=delVar(path,name)

%% PURPOSE: SMALL UTILITY TO LOAD ALL OF THE VARIABLES IN A MAT FILE, THEN DELETE THE SPECIFIED VARIABLE AND SAVE THE REST

load(path);

a=whos;
a={a.name};

a=a(~ismember(a,{name,'name','path'}));

save(path,a{:});