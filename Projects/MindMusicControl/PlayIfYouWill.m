[y,Fs] = audioread('Allegro from Duet in C Major.mp3');
player = audioplayer(y,44100);
while true
    condition  = getExecutive();
    condition1 = condition(1);
    condition2 = condition(2);
    if condition1
        player.play;
    elseif condition2
        player.pause;
    else
    end
end