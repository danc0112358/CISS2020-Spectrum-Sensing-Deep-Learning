%Set your working folder
workingfolder='.\';

%Set the name of the folder in which these images will be saved
outputfolder = 'Signal_Images_Interference';

%Set the SNR for the images
%The signal power will be set relative to the noise
%SNR can be set as a single value, or as a vector.
%If set as a vector, this script will create
%images corresponding to each desired SNR.
%If set as a single value, then only one
%SNR will be used for all images generated.
%SNR will be used to scale the signal 
%with respect to noise 
SNRVectordB=[0];

%Set the variance of the noise.
NoisePowDb=0;

fftlen=227;

symbolsamplen=fftlen*2;

OSRrate=4;
startpos=1;

datalen=ceil(symbolsamplen/OSRrate);


noiselength=fftlen*2;

NumberPerVar=400;
scaleval=2;

%Make the output folder if it does not exist
go_mkdir=1;
cd(workingfolder)
dc=dir('*.*');
for idx=3:length(dc)
    if strcmp(dc(idx).name,outputfolder)
        go_mkdir=0;
    end
end
if (1==go_mkdir)
    mkdir(outputfolder)
end

%Go to the output folder
cd([workingfolder '\' outputfolder])

%Create the images
for VarIdx=1:length(SNRVectordB)
    VardB=SNRVectordB(VarIdx)+NoisePowDb;
  
    for iteridx=1:NumberPerVar
        
		%Create the signal
        datavec = randi([0 1],1,datalen);
        symbolvec=(datavec*2)-1;
        symbolvecosr=repelem(symbolvec,OSRrate);
        symbolvecosr=symbolvecosr(1:noiselength);
        
        signalvec = zeros(1,noiselength);
        signalvec(startpos:startpos+length(symbolvecosr)-1) = symbolvecosr;
        signalvec=signalvec/sqrt(var(signalvec));
        SigPowLin=10^(VardB/10);
        signalvec=signalvec*sqrt(SigPowLin);
		
		%Create the random interference
        cwfreq=rand;
        cwamp=rand;
        
		%Create the noise
        VarLin=10^(-NoisePowDb/10);
        capturewaveform_noise = randn(1,noiselength);
        capturewaveform_noise=capturewaveform_noise+1.0i*randn(1,noiselength);
        capturewaveform_noise=capturewaveform_noise/sqrt(2);
        capturewaveform_noise=capturewaveform_noise*sqrt(VarLin);
		%Add the signal and the interferer
        capturewaveform=capturewaveform_noise+signalvec+cwamp*exp(2.0i*pi*[1:noiselength]*cwfreq);

        spectrogramcapture=zeros(fftlen,fftlen);
        image=zeros(fftlen,fftlen,3);
        for imageidx=1:fftlen
            %PSD will be spread across 256 bins.
            %PSD measured per bin, not per Hz.
            %10*log10(1/256) = -24.0824
            spectrogramcapture(imageidx,:)=fftshift(fft(capturewaveform(imageidx:imageidx+fftlen-1)/fftlen,fftlen));
            image(imageidx,:,1)=20*log10(abs(spectrogramcapture(imageidx,:)));  %20*log10
            image(imageidx,:,2)=20*log10(abs(spectrogramcapture(imageidx,:))); %.^2 
            image(imageidx,:,3)=20*log10(abs(spectrogramcapture(imageidx,:))); 
        end

        image=image-min(image(:));
        image=image*scaleval;%
        image=image/max(image(:));
        image=image*255;

        image=round(image);
        if max(image(:))>255
            disp('clipping!')
        end
        image(image>255)=255;
        
        image=uint8(image);
        
        
        filenamestr=['signal_' num2str(VardB) '_' num2str(iteridx) '.bmp'];
        imwrite(image,filenamestr,'bmp') 
        
    end
end

%Return to the Working diretcory
cd(workingfolder)