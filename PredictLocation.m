function [latitude, longitude] = PredictLocation(candidateLocations, method, Settings)
	
	% Given a set of candidate locations return the most likely estimated location.
	%
	% Inputs:	candidateLocations- Candidate locations is an array of latitude, longitude
	%		method - Similarity metric (JointScore or MatchScore)
	%		Settings - Application wide settings used to store algorithm parameters, paths etc.
	%
	% Outputs:	latitude - Estimated latitude
	%		longitude - Estimated longitude
	
	n = length(candidateLocations);
	positions = [candidateLocations.Latitude; candidateLocations.Longitude];    
	
	if(strcmp(method, 'JointScore'))	
		subtractedScores = bsxfun(@minus, 1, [candidateLocations.JointScore]); % Subtract scores, so that lower the values better the score    
	elseif(strcmp(method, 'MatchScore'))	
		subtractedScores = bsxfun(@minus, 1, [candidateLocations.MatchScore]); % Subtract scores, so that lower the values better the score
	else
		return;
	end
	
	weightedPositions = bsxfun(@times, positions, subtractedScores);
	sumOfScores = sum(subtractedScores);	
	latitude = sum(weightedPositions(1, : )) / sumOfScores;
	longitude = sum(weightedPositions(2, : )) / sumOfScores;	
end