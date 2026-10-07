function aggregate_model(f)
    ff = {'k_rho_alpha_ll_wmh'};
    Nsubj = 1000;
    
    LL = zeros(Nsubj,5);
    P = cell(1,Nsubj);
    K = zeros(1,Nsubj);
    
    for sj = 1:Nsubj
        fname = fullfile('capacity', ff{f}, sprintf('subj_%03d.mat',sj));
        if exist(fname,'file')
            load(fname);
            P{sj} = P;
            LL(sj,:) = LL;
            K(sj) = K_idx;
        end
    end
    
    save(fullfile('capacity', ['capacity_' ff{f} '.mat']), 'LL','P','K');
end
