% classify data here, make sure that is the same distance formula as the
% cluster.m file

% catagorize the points to the centorids
[~, test_idx] = pdist2(centroids, CNTY_COVID(testing_idx, :),'cosine','Smallest', 1);
testing_covid = CNTY_COVID(testing_idx, :);

found_divisions = [];
correct = [];

% find the sil values of the current testing set
sil_values = silhouette(CNTY_COVID(testing_idx, :), test_idx);

% for ecah testing index
for c = 1:length(test_idx)
    % this is the classification code that finds the division from the test
    % index then connects it to the definions of the centorids
    found_divisions(c) = centroid_labels(test_idx(c));
    correct(c) = (found_divisions(c) == testing{c, "DIVISION"});
end

% this code tests the num correct and the J values for the code
num_correct = sum(correct);
J = num_correct - (0.5*length(centroid_labels));

%run optetimation and see what is the best for performance and competion

