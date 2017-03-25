clear all;
clc;

% initial
ip = '0.0.0.0'; %Localhost
port = 5000;  %TCP Port (default port is 5000)

dlmwrite('csv_eegBuffer.csv',[]);

% make and open server
tcpServer=tcpip(ip, port, 'NetworkRole', 'server');
tcpServer.InputBufferSize = 5000;
fopen(tcpServer);

% hudpr = dsp.UDPReceiver('LocalIPPort',5000,'ReceiveBufferSize',65536,...
%     'MaximumMessageLength',8191);
% setup(hudpr);

exit = 0;
return_num = 0;
bytesReceived = 0;
dataReceived = [];

% DlgH = figure;
% H = uicontrol('Style', 'PushButton', ...
%                     'String', 'Break',...
%                 'Position',[400 45 120 20]);
display('Start of Acquisition');
runTime = datenum(clock + [0, 0, 0, 0, 0, 10]);
tic
while datenum(clock) < runTime
    try %Catch Matlab error
        a = fread(tcpServer, 4);  %How large is the package (# bytes)
    catch err;
        break
    end
    
    bytesToRead = double(swapbytes(typecast(uint8(a),'int32')));
    
    for ind = 1:bytesToRead
        try
            bytesData(ind) = DISread(serverDIS,'uint8');
        catch e; %catch "Java exception occurred"
            break
        end
    end
    if ind ~= bytesToRead
        break
    end
    
    % convert to data
    [oscPath, oscTag, oscData] = splitOscMessage(bytesData);
    data = oscFormat(oscTag,oscData);
    data = reshape(data,ceil(numel(data)/4),4);
    dlmwrite('csv_eegBuffer.csv',cell2mat(data),'-append');
    
    return_num = return_num + 1;
    %    dataReceived_temp = step(hudpr);
    %    dataReceived_temp2 = reshape(dataReceived_temp, [4 size(dataReceived_temp,1)/4]);
    %    dataReceived_temp2
    %    dataReceived = [dataReceived dataReceived_temp2];
    %    bytesReceived = bytesReceived + length(dataReceived_temp);
end
toc


fclose(tcpServer);
delete(tcpServer);


display('End of Acquisition');