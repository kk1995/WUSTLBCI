clear all;
clc;


hudpr = dsp.UDPReceiver('LocalIPPort',5000,'ReceiveBufferSize',65536,...
    'MaximumMessageLength',8191);

setup(hudpr);
exit = 0;
return_num = 0;
bytesReceived = 0;
dataReceived = [];

DlgH = figure;
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break',...
                'Position',[400 45 120 20]);
while (ishandle(H))
   dataReceived_temp = step(hudpr);
   dataReceived_temp2 = reshape(dataReceived_temp, [4 size(dataReceived_temp,1)/4]);
   dataReceived_temp2
   dataReceived = [dataReceived dataReceived_temp2];
   bytesReceived = bytesReceived + length(dataReceived_temp);
   return_num = return_num + 1;
   pause(0.01);
end
