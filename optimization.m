% this scirpt runs kmeans between clusters numbers 1:100 and then finds the best combination by doing that a specified number of times and averaging the results
tic;
load("COVIDbyCounty.mat");

CNTY_CENSUS.idx = (1:height(CNTY_CENSUS))'; 

states = {};
for c = 1:height(CNTY_CENSUS)
    state = CNTY_CENSUS{c, "STNAME"};
    if ismember(state, states) ~= 1
        states(length(states)+1)= state;
    end
end

correct_all = [];
J_all = [];
correct_maxes = [];
J_maxes = [];

distance_value = "cityblock";
number_g = 11;

for g = 1:number_g
    training = table;
    testing = table;

    for c = 1:length(states)
        idx = find(CNTY_CENSUS{:, "STNAME"} == string(states(c)));
        breakPoint = int16(length(idx)*0.75);
        idx_rand = idx(randperm(length(idx)));
        for d = 1:breakPoint
            training = [training;CNTY_CENSUS(idx_rand(d), :)];
        end
        for d = breakPoint+1:length(idx)
            testing = [testing;CNTY_CENSUS(idx_rand(d), :)];
        end
    end
    
    training_idx = training{:, "idx"};
    testing_idx = testing{:, "idx"};
    
    % write an optimization script here for kmeans finding the best number of
    % centorids
    
    J_values = [];
    correct_values = [];
    
    for num_clusters = 1:100
    
        [idx, centroids] = kmeans(CNTY_COVID(training_idx, :), num_clusters, "distance", distance_value);
        
        definitions = [];
        
        % Strategy 1
        for c = 1:height(centroids)
            divisionCounts_curr = [];
            table_current = training(idx == c, :);
            for d = 1:9
                divisionCounts_curr(d) = height(table_current(table_current{:, "DIVISION"} == d, :));
            end
            [~,I] = max(divisionCounts_curr);
            definitions(c) = I;
        end

        [~, test_idx] = pdist2(centroids, CNTY_COVID(testing_idx, :), distance_value, 'Smallest', 1);
        
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
    
    correct_all = [correct_all;correct_values];
    J_all = [J_all; J_values];
    [M, I] = max(correct_values);
    correct_maxes = [correct_maxes;[M I]];
    [M, I] = max(J_values);
    J_maxes = [J_maxes;[M I]];

end
% creating a plot
figure

for g = 1:number_g
    subplot(3, 4, g)
    title("for run " + string(g))
    plot(correct_all(g, :))
    hold on
    plot(J_all(g, :))
    plot(correct_maxes(g, 2), correct_maxes(g, 1), "o")
    plot(J_maxes(g, 2), J_maxes(g, 1), "o")
    xlabel("number of centroids")
    ylabel("value")
    hold off
end

subplot(3, 4, number_g+1)
hold on
title("data for " + distance_value)
avg_max_correct = sum(correct_maxes(:, 1))/height(correct_maxes);
avg_index_correct = sum(correct_maxes(:, 2))/height(correct_maxes);
text_format = ("avg max correct: " + string(avg_max_correct) + ", cluster count: " + string(avg_index_correct));
text(0.3, 0.3, text_format)
avg_max_J = sum(J_maxes(:, 1))/height(J_maxes);
avg_index_J = sum(J_maxes(:, 2))/height(J_maxes);
text_format = ("avg max J: " + string(avg_max_J) + ", cluster count: " + string(avg_index_J));
text(0.2, 0.2, text_format)
text(0.4, 0.4, "blue line is for correct values")
text(0.5, 0.5, "orange line is for j values")
text_format = ("time passed: " + string(toc) + " seconds");
text(0.1, 0.1, text_format)
hold off