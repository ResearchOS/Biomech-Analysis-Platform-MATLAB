function [sid]=getComputerID()

%% PURPOSE: GET A UNIQUE IDENTIFIER FOR EACH COMPUTER

sid = '';
ni = java.net.NetworkInterface.getNetworkInterfaces;
while ni.hasMoreElements
    addr = ni.nextElement.getHardwareAddress;
    if ~isempty(addr)
        addrStr = dec2hex(int16(addr)+128);
        sid = [sid, '.', reshape(addrStr,1,2*length(addr))];
    end
end

sid=getvarname(sid);