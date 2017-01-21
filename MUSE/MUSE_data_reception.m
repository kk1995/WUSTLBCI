clear all;
clc;


hudpr = dsp.UDPReceiver('LocalIPPort',5000);

setup(hudpr);
exit = 0;
return_num = 0;
bytesReceived = 0;
dataReceived = [];

while exit == 0
   dataReceived_temp = step(hudpr);
   dataReceived_temp2 = reshape(dataReceived_temp, [4 size(dataReceived_temp,1)/4]);
   dataReceived_temp2
   dataReceived = [dataReceived dataReceived_temp2];
   bytesReceived = bytesReceived + length(dataReceived_temp);
   return_num = return_num + 1;
end