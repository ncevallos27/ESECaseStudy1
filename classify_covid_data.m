load("COVIDbyCounty.mat");

% take each state entries and split into two random groups one with 3/4 of
% data and the other with 1/4 of the data, the smaller will be the test
% group
% if there is only one entry in state then put into group that is
% mismatched, if there is no group that is mismatched then randomly assign
% it into testing or training set. If number of state entries is odd then
% add the smaller or bigger one to the mismatched group so the make them
% equal after adding

states = {};
for c = 1:height(CNTY_CENSUS)
    state = CNTY_CENSUS{c, "STNAME"};
    CNTY_CENSUS(c, "Idx") = c;
    if ismember(state, states) ~= 1
        states(length(states)+1)= state;
    end
end

training = table;
testing = table;

for c = 1:length(states)

end



