function [id]=getComputerID()

%% PURPOSE: GET A UNIQUE IDENTIFIER FOR EACH COMPUTER

% DOES NOT WORK, IS NOT STATIC: The "Other platforms" section of this Undocumented MATLAB page: https://undocumentedmatlab.com/blog_old/unique-computer-id#comment-511840

% Current method taken from this page: https://www.mathworks.com/matlabcentral/answers/101892-what-is-a-host-id-how-do-i-find-my-host-id-in-order-to-activate-my-license

try
    id = getCurrent('Computer_ID');
    if ~isempty(id) && ~isstruct(id) && ~isequal(id,'NULL')
        return;
    end
catch

end

if ismac==1
    [~,id]=system('ifconfig en0 | grep ether');
elseif ispc==1
    [~,a]=system('getmac');
    equalsIdx=ismember(a,'=');
    lastEquals=find(equalsIdx==1,1,'last');
    shortA=a(lastEquals+1:end); % Trim after the last equals sign.
    spaceIdx=strfind(shortA,' ');
    id=shortA(1:spaceIdx(1)-1); % Isolate the physical address
end

id=genvarname(id);

setCurrent(id,'Computer_ID');