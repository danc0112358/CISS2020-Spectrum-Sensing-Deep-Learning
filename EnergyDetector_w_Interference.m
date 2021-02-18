%Simulation Parametrers
LenMvAvg=227+226;  %Same length as the Alexnet Signal Detector
ApproxNumberOfSamplesPerRun=1e6;      %approximate # samples to run
SignalToNoisePowerVector=-9:0.1:0; %a vector of SNR values
ThresholdVector=1.2:0.01:1.7;              %a vector of threshold values

OverSamp=4;




%Plot across Threshold at this SNR value
SNRValueToPlot=SignalToNoisePowerVector(ceil(length(SignalToNoisePowerVector)/2));
SNRValueIndexToPlot=ceil(length(SignalToNoisePowerVector)/2);

%Random data
ActualNumberOfSamplesPerRun=ApproxNumberOfSamplesPerRun+OverSamp*LenMvAvg;
ActualNumberOfSamplesPerRun=ceil(ActualNumberOfSamplesPerRun/OverSamp)*OverSamp;
rxdVector=randi([0 1],1,ActualNumberOfSamplesPerRun/OverSamp);
rxdVector=(rxdVector*2)-1;
rxdVector=repelem(rxdVector,OverSamp);
ActualNumberOfSamplesPerRun=length(rxdVector);  % determine actual # of samples


%Create the noise vector once, reuse later
NoiseVector=randn(1,ActualNumberOfSamplesPerRun);
NoiseVector=NoiseVector+1.0i*randn(1,ActualNumberOfSamplesPerRun);
NoiseVector=NoiseVector/sqrt(2);


cwfreq=0.00;
jammersig=1.0*exp(2.0i*pi*[1:ActualNumberOfSamplesPerRun]*cwfreq);

%Create a 2D array of result values.
%Oragnize by 
%Rows=SNR
%Columns=Threshold
FalseAlarmRate=zeros(length(SignalToNoisePowerVector),length(ThresholdVector));
MissedDetectRate=zeros(length(SignalToNoisePowerVector),length(ThresholdVector));

%Simulate and collect FA and MD results
snridxcount=0;
for snridx=SignalToNoisePowerVector
    snridxcount=snridxcount+1;
    NoisePower=10^-(0/10);
	%Add interference to noise
    NoiseVectorlocal=sqrt(NoisePower)*NoiseVector+jammersig;
    ConjProduct=NoiseVectorlocal.*conj(NoiseVectorlocal);
    ConjProduct=sqrt(real(ConjProduct));
    CorrelatedNoise=conv(ConjProduct,ones(1,LenMvAvg));    
    CorrelatedNoise=CorrelatedNoise/LenMvAvg;
    CorrelatedNoise=CorrelatedNoise((1+LenMvAvg):(end-LenMvAvg));
    CorrelatedNoise=downsample(CorrelatedNoise,LenMvAvg);
    LenVal=length(CorrelatedNoise);
    threshidxcount=0;
    for threshidx=ThresholdVector
        threshidxcount=threshidxcount+1;
        FalseAlarmRate(snridxcount,threshidxcount)=sum(CorrelatedNoise>=threshidx)/LenVal;
    end
    
    NoiseVectorlocal=sqrt(NoisePower)*NoiseVector;
    SignalPower=10^(snridx/10);
    rxdVectorlocal=rxdVector*sqrt(SignalPower);
	%Add interference and signal to noise	
    NoiseVectorlocal=NoiseVectorlocal+rxdVectorlocal+jammersig;
    ConjProduct=NoiseVectorlocal.*conj(NoiseVectorlocal);
    ConjProduct=sqrt(real(ConjProduct));
    CorrelatedNoise=conv(ConjProduct,ones(1,LenMvAvg));
    CorrelatedNoise=CorrelatedNoise((1+LenMvAvg):(end-LenMvAvg));
    CorrelatedNoise=CorrelatedNoise/LenMvAvg;
    CorrelatedNoise=downsample(CorrelatedNoise,LenMvAvg);
    LenVal=length(CorrelatedNoise);
    threshidxcount=0;
    for threshidx=ThresholdVector
        threshidxcount=threshidxcount+1;
        MissedDetectRate(snridxcount,threshidxcount)=sum(CorrelatedNoise<threshidx)/LenVal;
    end    
    
end