% classify data here, make sure that is the same distance formula as the
% cluster.m file
[~, test_idx] = pdist2(centroids, CNTY_COVID(testing_idx, :),'cosine','Smallest', 1);

testing_covid = CNTY_COVID(testing_idx, :);

found_divisions = [];
correct = [];

sil_values = silhouette(CNTY_COVID(testing_idx, :), test_idx);
for c = 1:length(test_idx)
    found_divisions(c) = definitions(test_idx(c));
    correct(c) = (found_divisions(c) == testing{c, "DIVISION"});
end

num_correct = sum(correct);

J = num_correct - (0.5*length(definitions));

%run optetimation and see what is the best for performance and competion

