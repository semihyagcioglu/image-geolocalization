function normalizedData = NormalizeData(data, min, max, average, method, sigma)

	% Normalize data
	%
	% Inputs:	data - Input data to be  normalized
	%		min - Minimum of the data range
	%		max - Maximum of the data range
	%		average - Average of the data range
	%		method - Method to use in normalization
	%		sigma - Sigma for exponential normalization
	%
	% Outputs:	normalizedData - Normalized data

	if(strcmp(method,'EXP'))
		normalizedData = exp(-((data)^2 ./ (2 * (sigma * average)^2))); % Subtract from sigma so that higher values are better scores.
	elseif(strcmp(method,'MAX')) 
		normalizedData = 1 - ((data - min) ./ (max - min));
	else
		normalizedData = 0;
		disp('Error in normalization!');
	end
end