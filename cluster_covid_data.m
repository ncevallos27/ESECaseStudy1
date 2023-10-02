% TODO OPTIMIZE SCRIPT

load("COVIDbyCounty.mat");
rng(1);

CNTY_CENSUS.idx = [1:height(CNTY_CENSUS)]'; 

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

[idx, centroids] = kmeans(CNTY_COVID(training_idx, :), 9, 'Distance', "cosine");

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