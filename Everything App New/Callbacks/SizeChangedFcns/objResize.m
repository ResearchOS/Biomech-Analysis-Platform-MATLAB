function []=objResize(obj,relPos,size)

%% PURPOSE: RESIZE THE SPECIFIED OBJECT
newFontSize=evalin('caller','newFontSize;');
figSize=evalin('caller','figSize;');

% Size can be specified as relative or absolute
if size(2)>2 % Absolute
    pos=round([relPos.*figSize size(1)*figSize(1) size(2)]);
else % Relative
    pos=round([relPos.*figSize size.*figSize]);
end

obj.Position=pos;

try
    obj.FontSize=newFontSize;
catch

end