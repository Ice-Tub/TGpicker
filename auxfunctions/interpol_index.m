function [ind] = interpol_index(opt, tp, geoinfo, layer, x_trace, current_window, leftright)
%MEAN_PEAK_INDEX Summary of this function goes here
%   Detailed explanation goes here

% -------------------------------------------------------------------------
% window should not be too big if one has to deal with either steep rises
% or thin layers (for thin layers looking for peaks only seems to be good
% approach)
% -------------------------------------------------------------------------
% POSSIBLE IMPROVEMENTS
% - only use linear regression when more than one peak is found? (otherwise 
%   fit might not work properly)
% - the prominence of the peaks could be used as weight factor


ub = floor(length(current_window)/2);
lmid = round(length(current_window)/2);

% adapt sizes of averaging window at the edges of the radargram
if x_trace > size(geoinfo.data,2)-ub 
    ind_clms = x_trace-ub:size(geoinfo.data,2);
    ind_trace = lmid;
elseif x_trace < ub + 1
    ind_clms = 1:x_trace+ub;
    ind_trace = x_trace;
    
else
    ind_clms = x_trace-ub:x_trace+ub;
    ind_trace = lmid;
end

% calculate the mean index (indices are weighted with prominence) which
% one would expect from the surrounding intensity extrema 
ind_y = [];
ind_x = [];

for ii = 1:length(ind_clms)
    
    % find either local maxima or minima
    [lind, ~] = find_max_min(opt, geoinfo.data(current_window, ind_clms(ii)));
    
    if isempty(lind)
        continue
    end
    
    % save row and column indices of the respective extrema
    if ~isnan(lind)
        ind_y = [ind_y; lind];
        ind_current_clm = ones(length(lind), 1)*ii;
        ind_x = [ind_x; ind_current_clm];
    end
     
       
end

    % assume that layer propagates linearly within the small window;
    % calculate linear regression 
    if ~isempty(ind_y)
        X = [ones(length(ind_x),1) ind_x];
        lin_coeff = X\ind_y;

        % calculate the row index at x_trace according to linear model
        ind = round(lin_coeff(1) + lin_coeff(2)*ind_trace);
        if ind > length(current_window)
            ind = length(current_window);
        elseif ind < 1
            ind = 1;
        end
    else
        ind = pick_nopeak(layer, x_trace, current_window, leftright, tp.nopeaks_window); 
    end


end

