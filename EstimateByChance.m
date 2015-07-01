function [RandomCandidateList, latitudeRandom,  longitudeRandom] = EstimateByChance(Candidates, Size, Settings)

	% Predict a location using the given candidate locations
	%
	% Inputs:	Candidates - Initial candidates to select from
	% 			Size - Number of candidates to be selected randomly
	%			Settings - Application wide settings used to store algorithm parameters, paths etc.
	%
	% Outputs:	RandomCandidateList - Set of  candidates selected randomly
	%			latitudeRandom - A latitude estimation, computed as the center of all candidates
	%			longitudeRandom - A longitude estimation, computed as the center of all candidates
	
    r = randi(length(Candidates), Size, 1); % Get random integers
	RandomCandidateList = Candidates(r);
	
	latitudeRandom = mean([RandomCandidates.Latitude]);
	longitudeRandom = mean([RandomCandidates.Longitude]);     
end