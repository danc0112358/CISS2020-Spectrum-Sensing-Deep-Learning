%Analysis

%Noise images will have lower indices than signal images.
%Set Threshold equal to number of noise images
Thresh=200;  %for 200 noise images

AlexFalseAlarmRate=0;
AlexMissedDetectRate=0;
for idx=1:length(actualclass)
    if predictedclass(idx) ~= actualclass(idx)
        if idx<=Thresh
		%If index is lower than or equal to Thresh, 
		%then the image was noise image but classified
		%as a signal image
            AlexFalseAlarmRate=AlexFalseAlarmRate+1;
        else
		%If index is greater than Thresh, 
		%then the image was signal image but classified
		%as a noise image		
            AlexMissedDetectRate=AlexMissedDetectRate+1;
        end
    end
end