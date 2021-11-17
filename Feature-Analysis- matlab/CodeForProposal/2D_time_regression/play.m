c={'r', 'g', 'k', 'y', 'm'};
close all
for ind = 1: size(N_Hands_3D_T,1)
   
    figure(ind);
    for roi = 1: size(N_Hands_3D_T,2)
        current_s = reshape(N_Hands_3D_T(ind,roi,:),1,size(N_Hands_3D_T,3));
        
        plot(current_s, 'color', c{roi})
        hold on
        
    end
    
end


c={'r', 'g', 'k', 'y', 'm'};
for i=1:size(f,1)
    figure(i);
    for roi =1 :7

        st = reshape(X_cube(i,roi,:),1,size(X_cube,3));
        xl_s = 1:size(X_cube, 3);
        subplot(1,3,1);
        m1=ALP_model.f_multiscale{1};
        original=reshape(m1(i,roi,:), 1,size(m1,3));
        xl_e = xl_s(end)+1:xl_s(end)+size(m1,3);
        plot(xl_e, original', 'color',c{roi},'LineStyle', '-');
        hold on
        approx = reshape(f_cube(i,roi,:), 1, size(m1,3));
        plot(xl_e, approx','color', c{roi}, 'LineStyle', '--');
        plot(xl_s, st', 'color', c{roi}, 'LineStyle', '--');
        g = get(gca);
        plot([xl_s(end), xl_s(end)],g.YLim, 'color', [0.5, 0.5, 0.5]);

        subplot(1,3,2);
        m2=ALP_model.f_multiscale{4};
        original=reshape(m2(i,roi,:), 1,size(m1,3));
        plot(xl_e, original', 'color',c{roi},'LineStyle', '-');
        hold on
        approx = reshape(f_cube(i,roi,:), 1, size(m1,3));
        plot(xl_e, approx','color', c{roi}, 'LineStyle', '--');
        plot(xl_s, st', 'color', c{roi}, 'LineStyle', '--');
        g = get(gca);
        plot([xl_s(end), xl_s(end)],g.YLim, 'color', [0.5, 0.5, 0.5]);

        subplot(1,3,3);
        m2=ALP_model.f_multiscale{8};
        original=reshape(m2(i,roi,:), 1,size(m1,3));
        plot(xl_e, original', 'color',c{roi},'LineStyle', '-');
        hold on
        approx = reshape(f_cube(i,roi,:), 1, size(m1,3));
        plot(xl_e, approx','color', c{roi}, 'LineStyle', '--');
        plot(xl_s, st', 'color', c{roi}, 'LineStyle', '--');
        g = get(gca);
        plot([xl_s(end), xl_s(end)],g.YLim, 'color', [0.5, 0.5, 0.5]);

    end

end

