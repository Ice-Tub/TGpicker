function [geoinfo] = pick_surface(geoinfo,echogram,MinBinForSurfacePick,smooth)

   if nargin < 3
    MinBinForSurfacePick =   1000;
   end
  
   if nargin < 4
    smooth =   30;
   end

[~,FirstArrivalInds] = max(echogram(MinBinForSurfacePick:end,:)); 
 FirstArrivalInds = floor(movmean(FirstArrivalInds,smooth));
 FirstArrivalInds = FirstArrivalInds+MinBinForSurfacePick;
 
 dt=geoinfo.time_range(2)-geoinfo.time_range(1);
 t1=geoinfo.time_range(1);
 Surface_pick_time=(FirstArrivalInds*dt)+t1;
 geoinfo.traveltime_surface=Surface_pick_time;
end

 
