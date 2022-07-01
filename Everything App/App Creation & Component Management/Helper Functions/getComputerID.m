function [id]=getComputerID()

%% PURPOSE: GET A UNIQUE IDENTIFIER FOR EACH COMPUTER

% DOES NOT WORK, IS NOT STATIC: The "Other platforms" section of this Undocumented MATLAB page: https://undocumentedmatlab.com/blog_old/unique-computer-id#comment-511840

% Current method taken from this page: https://www.mathworks.com/matlabcentral/answers/101892-what-is-a-host-id-how-do-i-find-my-host-id-in-order-to-activate-my-license

if ismac==1
    [~,id]=system('ifconfig en0 | grep ether');
elseif ispc==1
    [~,a]=system('getmac');
    equalsIdx=ismember(a,'=');
    shortA=a(equalsIdx(end)+1:end); % Trim after the last equals sign.
    spaceIdx=ismember(shortA,' ');
    id=shortA(1:spaceIdx(1)-1); % Isolate the physical address
end

id=genvarname(id);


% sid = '';
% ni = java.net.NetworkInterface.getNetworkInterfaces;
% while ni.hasMoreElements
%     addr = ni.nextElement.getHardwareAddress;
%     if ~isempty(addr)
% %         sid = [sid, '.', sprintf('%.2X', typecast(addr, 'uint8'))]; % Modification from user comment by Jan Simon
%         addrStr = dec2hex(int16(addr)+128); % Original line by Yair Altman
%         sid = [sid, '.', reshape(addrStr,1,2*length(addr))]; % Original line by Yair Altman
%     end
% end
% 
% sid=genvarname(sid);