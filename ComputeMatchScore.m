function [score] = ComputeMatchScore(im1, im2, method, Settings)

	% Given two images, return a score based on their match cost. The lower, the better.
	%
	% Inputs:	im1 - Input image 1
	% 			im2 - Input image 2
	%			method - Match method (DSP or SIFT)
	%			Settings - Application wide settings used to store algorithm parameters, paths etc.
	%
	% Outputs:	score - Match cost, lower score means two images match better.
	
    score = 0;

    if(strcmp(method, 'DSP'))
        % pca_basis: pca basis for dimensionality reduction of sift
        %load('dsp/lmo_pca_basis.mat', 'pca_basis');
        pca_basis = []; % if you want to use the sift of original dimension
        sift_size = 4; % sift patch size 16 x 16 pixels (i.e., patch_size = 4*sift_size)
        % Extract SIFT
        [sift1, ~] = ExtractSIFT(im1, pca_basis, sift_size);
        [sift2, ~] = ExtractSIFT(im2, pca_basis, sift_size);
        [~, ~, match_cost] = DSPMatch(sift1, sift2); 
        score = mean2(match_cost); % Compute the score based on the match_cost of DSP matrix.
		
	else if(strcmp(method, 'SIFT'))	
		im1 = single(rgb2gray(im1)); % Convert to single, since it is recommended
		im2 = single(rgb2gray(im2));
		[F1 D1] = vl_sift(im1); % Extract sift features and descriptors
		[F2 D2] = vl_sift(im2); % Extract sift features and descriptors
		L2Ratio = Settings.L2Ratio4SIFT; % Euclidean distance ratio of NN2/NN1, used to filter matches		
		[matches score] = vl_ubcmatch(D1, D2, L2Ratio);		
		 score = mean2(score);
    end
end