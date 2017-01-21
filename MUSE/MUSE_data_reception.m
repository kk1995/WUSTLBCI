hudpr = dsp.UDPReceiver('LocalIPPort',5000);

setup(hudpr);

set(gcf,'CurrentCharacter','@'); % dummy character
exit = 0;
while exit == 0
  % check for keys
  k=get(gcf,'CurrentCharacter');
  if k~='@' % has it changed from the dummy character?
    set(gcf,'CurrentCharacter','@'); % reset the character
    % now process the key as required
    if k=='q', exit=1; end
  end
end