%This script takes LabChart data exported as a MATLAB file and finds the
%response time of our prototype as it transitions from one tissue to
%another

%Response time is calculated by first finding steady state frequency values
%for the initial tissue and then finding steady state frequency values for
%the final tissue that the prototype is inserted into
%The difference between initial and final steady states in calculated to
%determine overall change, response time is then measured as time it takes
%for the signal to reach 50%, 75% and 90% of it's final steady state value
%from it's initial steady state value

%Note for each response curve analyzed new initial and final steady time
%windows must be observed from LabChart data as well as a band of time
%around the transition curve itself.  The start time for the calculation
% of transition must also be determined from LabChart data.

%create a time data array with time element at every 1/samplerate step
time=0:1/tickrate:(dataend-1)/samplerate; 

data(isnan(data))=0; %replace any NaN values in data array with zeros

%find nearest endpoints in time array to a defined time period (0.4 sec) where data
%is in initial and final steady states
iss_ind=interp1(time, 1:length(time),41.025,'nearest'); %find nearest initial steady state time value to 10.8s
iss_ind_2=interp1(time, 1:length(time),41.425,'nearest'); %find nearest initial steady state time value to 11.3s

%average the initial and final steady state frequencies in data array to
%get average steady state frequencies
iss_freq =mean(data(iss_ind:iss_ind_2)); %take average of frequencies within the initial steady period
fss_ind=interp1(time, 1:length(time),41.55,'nearest'); %find nearest final ss time value to 11.6s
fss_ind_2=interp1(time, 1:length(time),41.95,'nearest'); %find nearest final ss time value to 12.1s
fss_freq=mean(data(fss_ind:fss_ind_2)); %take average of frequencies within the final steady period 

%store frequency values when signal reaches 50,75 & 905% of its steady
%state value
rt_freq1=fss_freq + 0.50*(iss_freq - fss_freq); %frequency value when signal reaches 50% of its final ss value
rt_freq2=fss_freq + 0.25*(iss_freq - fss_freq); %freq value when signal reaches 75% of final ss value
rt_freq3=fss_freq + 0.10*(iss_freq - fss_freq); %freq value when signal reaches 90% of final ss value

%define a band of time around the frequency transition of interest to look
%for times when rt_freq1 - 3 are reached
[calcband_start, calcband_start_idx]=min(abs(time-41.48)); %find index of start calc time value close to 11 s
[calcband_stop,calcband_stop_idx]=min(abs(time-41.525));%find index of stop calc time value close to 12 s
dataslice=data(calcband_start_idx:calcband_stop_idx); %slice data to within start and stop band times
timeslice=time(calcband_start_idx:calcband_stop_idx); %slice time to within start and stop band times

%find start time of transition based on video observation (find nearest to
%observed time within timeslice)
[time_start, time_start_index]=min(abs(timeslice-23.66));
starttime=timeslice(time_start_index);

%find time when frequency is at rt_freq1 (50% of ss value)
[data_rt1, data_rt1_idx]=min(abs(dataslice-rt_freq1)); %finds idx of dataslice closest to rt_freq1
percent50sstime=timeslice(data_rt1_idx);
responsetime50=percent50sstime-starttime;

%find time when frequency is at rt_freq1 (75% of ss value)
[data_rt2, data_rt2_idx]=min(abs(dataslice-rt_freq2)); %finds idx of dataslice closest to rt_freq1
percent75sstime=timeslice(data_rt2_idx);
responsetime75=percent75sstime-starttime;

%find time when frequency is at rt_freq1 (90% of ss value)
[data_rt3, data_rt3_idx]=min(abs(dataslice-rt_freq3)); %finds idx of dataslice closest to rt_freq1
percent90sstime=timeslice(data_rt3_idx);
responsetime90=percent90sstime-starttime;

plot(time(iss_ind:fss_ind_2), data(iss_ind:fss_ind_2))
y = ylim; % current y-axis limits
line([percent50sstime percent50sstime],[y(1) y(2)],'Color','red','LineStyle','--')
line([percent75sstime percent75sstime],[y(1) y(2)],'Color','green','LineStyle','--')
line([percent90sstime percent90sstime],[y(1) y(2)],'Color','blue','LineStyle','--')
%plot(percent50sstime,0)
%xline(percent50sstime,'-',{'50% of ss'});
%h = vline(percent50sstime,0,'50% of ss')
