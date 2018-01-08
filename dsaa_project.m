clc
clear
close all
load 103m.mat
ecg = val;
samplingrate = 1000;

%   Remove lower frequencies
fresult=fft(ecg);
fresult(1 : round(length(fresult)*5/samplingrate))=0;
fresult(end - round(length(fresult)*5/samplingrate) : end)=0;
corrected=real(ifft(fresult));

%   Filter - first pass
WinSize = floor(samplingrate * 571 / 1000);
if rem(WinSize,2)==0
    WinSize = WinSize+1;
end
filtered1=ecgdemowinmax(corrected, WinSize);
%   Scale ecg
peaks1=filtered1/(max(filtered1)/7);
%   Filter by threshold filter
for data = 1:1:length(peaks1)
    if peaks1(data) < 4
        peaks1(data) = 0;
    else
        peaks1(data)=1;
    end
end
positions=find(peaks1);
distance=positions(2)-positions(1);
for data=1:1:length(positions)-1
    if positions(data+1)-positions(data)<distance
        distance=positions(data+1)-positions(data);
    end
end
% Optimize filter window size
QRdistance=floor(0.04*samplingrate);
if rem(QRdistance,2)==0
    QRdistance=QRdistance+1;
end
WinSize=2*distance-QRdistance;
% Filter - second pass
filtered2=ecgdemowinmax(corrected, WinSize);
peaks2=filtered2;
for data=1:1:length(peaks2)
    if peaks2(data)<4
        peaks2(data)=0;
    else
        peaks2(data)=1;
    end
end

subplot(2,1,1)
plot(ecg)
subplot(2,1,2)
plot(corrected)
subplot(2,1,1)
plot(corrected)
hold on;
plot(peaks1*140,'r')
subplot(2,1,2)
plot(corrected)
hold on;
plot(peaks2*140,'r')



%averageDistance = mean(distance);
%heartBeatsPerMinute = 60 / averageDistance*1000;
%heartBeatsPerMinute,

intervals = zeros(1,length(positions)-1);
for i = 2:1:length(positions)
  intervals(i-1) = positions(i) - positions(i-1);
end

averageDistance = mean(intervals);
heartrate = averageDistance/360;
60/heartrate;
if heartrate > 1
  msgbox("Patient shows signs of Bradycardia.");
elseif heartrate < 0.6
  msgbox("Patient shows signs of Supraventricular Tachycardia.");
endif

output = zeros(1,2);
for i = 1:1:length(intervals)
  if intervals(i) > 1.5*averageDistance % || (distance(i) > (averageDistance + 2*std(distance)))
    output(1) = 1;
  elseif intervals(i) < averageDistance/1.5 % || (distance(i) < (averageDistance - 2*std(distance)))
    output(2) = 1;
  endif
end

if output(1) == 1
  msgbox("Patient shows signs of missed beats.")
endif

if output(2) == 1
  msgbox("Patient shows signs of Premature Ventricular Contractions.")
endif
