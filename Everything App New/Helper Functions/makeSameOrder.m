function [c, reorderedVector] = makeSameOrder(templateVector, vectorToReorder)

%% PURPOSE: REORDER THE 'vectorToReorder' TO BE IN THE SAME ORDER AS THE TEMPLATE.
% Outside of this function, can check that the "reorderedVector" and
% "templateVector" are organized identically.

[a,b,c]=intersect(templateVector, vectorToReorder,'stable');
reorderedVector = vectorToReorder(c);