% TODO OPTIMIZE SCRIPT

load("COVIDbyCounty.mat");

CNTY_CENSUS.idx = (1:height(CNTY_CENSUS))'; 

training = table;
testing = table;

states = {};
for c = 1:height(CNTY_CENSUS)
    state = CNTY_CENSUS{c, "STNAME"};
    if ismember(state, states) ~= 1
        states(length(states)+1)= state;
    end
end

for c = 1:length(states)
    idx = find(CNTY_CENSUS{:, "STNAME"} == string(states(c)));
    breakPoint = int16(length(idx)*0.75);
    for d = 1:breakPoint
        training = [training;CNTY_CENSUS(idx(d), :)];
    end
    for d = breakPoint+1:length(idx)
        testing = [testing;CNTY_CENSUS(idx(d), :)];
    end
end

training_idx = training{:, "idx"};
testing_idx = testing{:, "idx"};

% write an optimization script here for kmeans finding the best number of
% centorids

J_values = [];
correct_values = [];

distance_value = "euclidean";

for num_clusters = 1:100

    [idx, centroids] = kmeans(CNTY_COVID(training_idx, :), num_clusters);
    
    definitions = [];
    
    for c = 1:height(centroids)
        divisionCounts_curr = [];
        table_current = training(idx == c, :);
        for d = 1:9
            divisionCounts_curr(d) = height(table_current(table_current{:, "DIVISION"} == d, :));
        end
        [~,I] = max(divisionCounts_curr);
        definitions(c) = I;
    end
    
    
    [~, test_idx] = pdist2(centroids, CNTY_COVID(testing_idx, :), distance_value,'Smallest', 1);
    
    testing_covid = CNTY_COVID(testing_idx, :);
    
    found_divisions = [];
    correct = [];
    
    for c = 1:length(test_idx)
        found_divisions(c) = definitions(test_idx(c));
        correct(c) = (found_divisions(c) == testing{c, "DIVISION"});
    end
    
    correct_values(num_clusters) = sum(correct);
    
    J_values(num_clusters) = sum(correct) - (0.5*length(definitions));

end

figure
plot(correct_values)
hold on
plot(J_values)
legend("correct", "J values")

[M, I] = max(correct_values)
[M, I] = max(J_values)