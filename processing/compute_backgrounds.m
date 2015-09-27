function [ns, nscondition] = compute_backgrounds(pars, i, tin)

% From a neuron psth returns the raw firing rate 
% (obtained by a spike count), averaged over trials for
% all the bitcodes, in a time window of length
% tin before stimulus onset

n = pars.general.nbitcodes;

tbefore = -tin/1e3;
count = 0;
ns = [];
nscondition = zeros(n,1);
at = load_aligned_trials_from_index(pars, i);

for j = 1 : n
    t = at{j};
    m = numel(t);
    
    M = 0;
    for k = 1 : m
        tt = t{k};
        tt = tt(tt > tbefore);
        count = count + 1;
        ns(count) = sum(tt < 0); 
        M = M + ns(count);
    end
    
    nscondition(j) = M/m;
    
    
end

% normalize in spikes per second

ns = ns*1e3/tin;
nscondition = nscondition*1e3/tin;


end