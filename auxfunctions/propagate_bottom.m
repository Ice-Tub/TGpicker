function bottom = propagate_bottom(bottom,geoinfo,tp,opt,x_in,y_in,leftright,editing_mode)
%PROPAGATE_BOTTOM automatically propagates a radar layer
%   Detailed explanation goes here
    lmid = round(tp.window/2);

    x_trace = x_in;
    
    nx = size(geoinfo.data, 2);
    continue_loop = 1;
    while continue_loop
        if x_trace == x_in
            y_trace = y_in;
        else
            if strcmpi(opt.input_type, 'MCoRDS')
                [~,lind,~,p] = findpeaks(mag2db(geoinfo.data(current_window,x_trace))); % need to do this on the bare data.
                
            elseif strcmpi(opt.input_type, 'GPR_LF') || strcmpi(opt.input_type, 'GPR_HF') || strcmpi(opt.input_type, 'awi_flight') || strcmpi(opt.input_type, 'PulsEKKO')
                
                % layer is propagated either by direct intensity extrema or
                % median intensity extrema
                if opt.median_peaks
                    [lind,p] = peaks_median(opt, geoinfo, current_window, x_trace);
                elseif opt.interpol_peaks
                    lind = interpol_index(opt, tp, geoinfo, bottom, x_trace, current_window, leftright); % always only returns one index
                else
                   [lind,p] = find_max_min(opt, geoinfo.data(current_window,x_trace));
                end
                  
            end
            if length(lind)==1
                y_trace = current_window(lind);
            elseif length(lind)>1
                %disp('***largest & closest peak.')     
                %wdist = 1-abs(2*(lind - lmid)/(tp.window)); % zwischen 0 und 1, with 1 being closer, so it will have more weight in next step 
                %lprobability = wdist + p/mean(p); %not perfect, but gives a tool to weigh proximity relative to brightness 
                %lprobability = wdist .* p/mean(p);   % try alternatives
                %lprobability = wdist .* p/sum(p);
                %lprobability = wdist + p/sum(p);
                probabilities = weigh_peaks(bottom, x_trace, lind, p, lmid, leftright, tp.weight_factor);
                [~, indprob] = max(probabilities);
                y_trace = current_window(lind(indprob));
            else
                % y_trace does not change
                
                % If activated, use direction of last update for current
                % one
                if opt.nopeak_step
                    
                    lind = pick_nopeak(bottom, x_trace, current_window, leftright, tp.nopeaks_window);
                    y_trace = current_window(lind);
                end
            end  
        end
        
        bottom(x_trace) = y_trace;
        
        
        % calculate current window (take care that it does not exceed
        % possible row indices) ADD UPPER LIMIT
        if y_trace > tp.rows(end)-floor(tp.window/2)  
            current_window = tp.rows(end)-tp.window+1:tp.rows(end);
        elseif y_trace < lmid
            current_window = 1:floor(y_trace + tp.window/2);
        else    
            current_window = ceil(y_trace-tp.window/2):floor(y_trace+tp.window/2);
        end

        x_trace = x_trace + leftright; % moves along the traces progressively, according to selected direction
        
        if editing_mode
            edit_min = max(1, x_in-opt.editing_window);
            edit_max = min(nx, x_in+opt.editing_window);
            continue_loop = ismember(x_trace, edit_min:edit_max);
        else
            continue_loop = ismember(x_trace, 1:nx);
        end
    end
end

