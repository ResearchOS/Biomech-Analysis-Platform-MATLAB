function []=resizeObj(obj,relPos,size,newFontSize,compHeight)

%% PURPOSE: RESIZE ANY OBJECT THAT HAS BEEN PASSED TO THIS FUNCTION.

if exist('compHeight','var')~=1
    compHeight=round(1.67*newFontSize); % Set the component heights that involve single lines of text}
end

if newFontSize==0 % Enter zero to not change the font size.
    fontBool=false;
else
    fontBool=true;
end

if any(size<10)
    size=
    