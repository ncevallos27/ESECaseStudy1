% load the data
load("COVIDbyCounty.mat");

% adding an idx coloumn to the CNTY CENSUS so that I can reference it later
CNTY_CENSUS.idx = [1:height(CNTY_CENSUS)]'; 

training = table;
testing = table;

% this for loop finds all the states in the city census
states = {};
for c = 1:height(CNTY_CENSUS)
    state = CNTY_CENSUS{c, "STNAME"};
    if ismember(state, states) ~= 1
        states(length(states)+1)= state;
    end
end

% this for loop splits the data into two groups, training and testing
for c = 1:length(states)
    idx = find(CNTY_CENSUS{:, "STNAME"} == string(states(c)));
    % this is finding breakpoint which is 75% fo the array
    breakPoint = int16(length(idx)*0.75);
    % this code randomizes the data so that it is different each time
    idx_rand = idx(randperm(length(idx)));
    % this for loop does the actual spliting
    for d = 1:breakPoint
        training = [training;CNTY_CENSUS(idx_rand(d), :)];
    end
    for d = breakPoint+1:length(idx)
        testing = [testing;CNTY_CENSUS(idx_rand(d), :)]; 
    end
end

% this is finding the index for the training and testing groups
training_idx = training{:, "idx"};
testing_idx = testing{:, "idx"};

[idx, centroids] = kmeans(CNTY_COVID(training_idx, :), 40, 'Distance', "cosine");

centroid_labels = [];
% finding the definitions fo all the centrodis
for c = 1:height(centroids)
    divisionCounts_curr = [];
    table_current = training(idx == c, :);
    for d = 1:9
        divisionCounts_curr(d) = height(table_current(table_current{:, "DIVISION"} == d, :));
    end
    [~,I] = max(divisionCounts_curr);
    centroid_labels(c) = I;
end