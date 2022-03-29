function printlme(lme, contrasts)
if nargin < 2 || isempty(contrasts)
    [p, F, DFn] = lme.coefTest();
else
    [p, F, DFn] = lme.coefTest(contrasts);
end

DFd = lme.DFE;

fprintf('p = %0.05e | F(%d, %d) = %0.05f\n', p, DFn, DFd, F);
