function [sid]=getComputerID()

%% PURPOSE: GET A UNIQUE IDENTIFIER FOR EACH COMPUTER
% Taken from the "Other platforms" section of this Undocumented MATLAB page: https://undocumentedmatlab.com/blog_old/unique-computer-id#comment-511840

sid = '';
ni = java.net.NetworkInterface.getNetworkInterfaces;
while ni.hasMoreElements
    addr = ni.nextElement.getHardwareAddress;
    if ~isempty(addr)
        sid = [sid, '.', sprintf('%.2X', typecast(addr, 'uint8'))]; % Modification from user comment by Jan Simon
%         addrStr = dec2hex(int16(addr)+128); % Original line by Yair Altman
%         sid = [sid, '.', reshape(addrStr,1,2*length(addr))]; % Original line by Yair Altman
    end
end

sid=genvarname(sid);