function aggregate_model(f,data,day)
    ff = {'k_rho_alpha_ll_wmh','original_model_rlwm'};
    ffolder = ['day' num2str(day) filesep ff{f} filesep 'generated_from_' ff{data} filesep 'capacity' filesep];
    Nsubj = 1000;
    
    LL = zeros(Nsubj,5);
    P = cell(1,Nsubj);
    K = zeros(1,Nsubj);
    
    for sj = 1:Nsubj
        fname = fullfile([ffolder 'subj_' num2str(sj) '.mat']);
        if exist(fname,'file')
            load(fname);
            P{sj} = P;
            LL(sj,:) = LL;
            K(sj) = K_idx;
        end
    end
    
    save([ffolder 'capacity_k.mat'], 'LL','P','K');
end
