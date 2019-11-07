function textprogressbar(c, offset)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress 
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

% Adapted 18Aug2019 KS for Goard Lab Processing Code

%% Initialization
persistent strCR;           %   Carriage return pesistent variable

% Vizualization parameters
if nargin < 2
    offset = 5;
end
strDotsMaximum      = 30;   %   The total number of dots in a progress bar
barCharacter        = '.';

%% Main 
    c = floor(c * 100);
    percentageOut = [num2str(c) '%%'];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat(barCharacter,1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [repmat(' ', 1, offset), 'Progress: ' dotOut ' ' percentageOut ' Complete'];
    if c == 100
        strOut = [repmat(' ', 1, offset), 'Progress: ' dotOut ' ' percentageOut ' Complete\n'];
    end

    
    % Print it on the screen
    if strCR == -1
        % Don't do carriage return during first run
        fprintf('\n')  % newline first
        fprintf(strOut);  % Make a newline on first run
    elseif c == 100
        fprintf([strCR strOut]);
        clear strCR
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
