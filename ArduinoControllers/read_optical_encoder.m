% read from optical encoder
s = serialport('COM4', 9600); % make sure your arduino has the proper code ready
configureTerminator(s, 'CR/LF');
disp('Press any key to continue...')
pause

s.flush()
s.UserData = struct('Data', []);
configureCallback(s, 'terminator', @readData)
t_start = GetSecs;

disp('Recording...')
exp_dur = 6; % seconds
pause(exp_dur)

configureCallback(s, 'off');
data = s.UserData.Data(2:end);

disp('Finished, cleaning up.')

clear('s')


% the while loop seems to hang up matlab and it doesn't call the callbacks, so we need to use pause
% while (GetSecs - t_start) < exp_dur
%     if mod(GetSecs - t_start, 5) == 0
%         fprintf('Time elapsed: %0.2fs\n', GetSecs - t_start);
%     end
%     % trap in loop to wait
% end