file_pattern = 'pilot2/240228_EM_-k_rho_alpha_ll_wmh-ite';
day=1;

pl=[];
for ite=1:10
    load ([file_pattern num2str(ite)]);
    pl(ite)=sum(PL(1:end)); 
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Load parameters
load ([file_pattern num2str(min_index)]) % load best iteration (lowest posterior likelihood (pl))

% Transform parameters
transformed_E = 1./(1+exp(-E));
alpha = transformed_E(1,:);
lapse = transformed_E(2,:);
bias  = transformed_E(3,:);
decay = transformed_E(4,:);
rho   = transformed_E(5,:);

% save parameters
if day == 1
    save(['pilot2/parameters_WMH_pilot2.mat'], 'alpha', 'bias', 'decay', 'lapse', 'rho','mu','nu')
else
    save(['pilot2day2/parameters_WMH_retest.mat'], 'alpha', 'bias', 'decay', 'lapse', 'rho','mu','nu')
end

% Make figure
figure;
subplot(2,3,1)
hist(alpha)
title('alpha')
subplot(2,3,2)
hist(lapse)
title('lapse')
subplot(2,3,3)
hist(decay)
title('decay')
subplot(2,3,4)
hist(bias)
title('bias')
subplot(2,3,5)
hist(rho)
title('reliance rho')