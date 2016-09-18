function [ ] = ExampleUsage()
h = EmotivEEG;
h.Run

for i = 1:10
    data_local = h.data;
    data_local = data_local+1;
    surf(data_local);
    pause(0.5);
end


lastfilename = h.Record(30);
h.LoadRecordedData(lastfilename)
data_local = h.data;
surf(data_local);

delete(h);
end

