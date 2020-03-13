function dunnettTest(data) 
	disp('Ensure that your data is organized as observations x groups')
	pause
	[p, ~, stats] = anova1(data); %
	fprintf('Omnibus ANOVA p: %0.02f\n', p);
	if p > 0.05
		warning('Your data did not pass the omnibus ANOVA, the Dunnett test is not recommended')
	end

	
end