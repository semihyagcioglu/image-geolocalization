function [candidateLocations, outliers] = FurthestNeighbourRemoval(candidateLocations, method, Settings)

	% Remove furthers neighbours in two stages by employing a similarity based and a distance based approach
	%
	% Inputs:	candidateLocations - A set of candidates which contain inliers and outliers
	% 			method - A similarity metric (JointScore or MatchScore)
	%			Settings - Application wide settings used to store algorithm parameters, paths etc.
	%
	% Outputs:	candidateLocations - Inliers
	%			outliers - Outliers

	remaining = length(candidateLocations);
	
	%% PHASE 1: Remove furthest neighbours based on similarity.	
	minusFrom = 1;	
	if(strcmp(Settings.NormalizationMethod, 'exp'))
		minusFrom = Settings.Sigma;
	elseif(strcmp(Settings.NormalizationMethod, 'max'))
		minusFrom = 1;
	end	

	% Subtract scores, so that lower the values better the score.
    for k = 1:length(candidateLocations);
		if(strcmp(method, 'JointScore'))
			candidateLocations(k).AdjustedDistance = minusFrom - candidateLocations(k).JointScore;
		elseif(strcmp(method, 'MatchScore'))
			candidateLocations(k).AdjustedDistance = minusFrom - candidateLocations(k).MatchScore;
		end
		candidateLocations(k).AveragePairwiseDistance = 0; % A small fix for first outliers to make them have same fields with second outliers
    end
    
    distMin = min([candidateLocations.AdjustedDistance]);
    candidateLocations = nestedSortStruct(candidateLocations, 'AdjustedDistance'); % Sort by AdjustedDistance
	
    idx = [];
    for k = 1:length(candidateLocations)
        if((candidateLocations(k).AdjustedDistance > (1 + Settings.Epsilon) * distMin))
			if(remaining > Settings.NearestNeighbourNumber) % Make sure we have at least k items to triangulate.
				idx = [idx k];
				remaining = remaining - 1;
			else
                break;
            end
        end
    end
	
	outliersSimilarity = candidateLocations(idx);
    candidateLocations(idx) = []; % Remove outliers
	
	%% PHASE 2:  Remove furthest neighbours based on 2D distances
    positions = [candidateLocations.Latitude; candidateLocations.Longitude];	
	distances = dist(positions);
    dMax = max(distances(:));
    normalizedDistances = distances / dMax;
	
    for k = 1:length(candidateLocations);
        candidateLocations(k).AveragePairwiseDistance = mean(normalizedDistances(k,:));
		candidateLocations(k).AdjustedDistance = 0; % A small fix for first outliers to make them have same fields with second outliers
    end
    
	candidateLocations = nestedSortStruct(candidateLocations, 'AveragePairwiseDistance'); % Sort by AveragePairwiseDistance
    idx = [];
    for k = length(candidateLocations) :-1:1
        if(candidateLocations(k).AveragePairwiseDistance > Settings.NearestNeighbourThreshold)
			if(remaining > Settings.NearestNeighbourNumber) % Make sure we have at least k items to triangulate.
				idx = [idx k];
				remaining = remaining - 1;
			else
                break;
            end
        end
    end
	
	outliers2D = candidateLocations(idx);	
    candidateLocations(idx) = []; % Remove outliers
	
	outliers = [outliers2D, outliersSimilarity]; % Merge outliers obtained from two stages PHASE 1 and PHASE 2
end