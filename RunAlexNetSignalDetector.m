workingfolder='.\';
cd(workingfolder)

%Pull images from the test directory
%The test directory should have two subdirectories
%One subdirectory labeled "Noise", and the other "Signal"
testimgs = imageDatastore('Test','FileExtensions',{'.bmp'},'IncludeSubfolders',true,'LabelSource','foldernames');

%netTransfer is the retrained Alexnet model
[predictedclass,scores] = classify(netTransfer,testimgs);

%Take a sample of the results and plot them
idx = randperm(numel(testimgs.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(testimgs,idx(i));
    imshow(I)
    predictedlabel = predictedclass(idx(i));
    actuallabel = testimgs.Labels(idx(i));
    
    strlabel = string(predictedlabel);
    if actuallabel~=predictedlabel
       strlabel = replace(strlabel,'i','X');  %X Marks error
    end
    title(strlabel);
end

%Now calculate the overall accuracy
actualclass = testimgs.Labels;
predictionaccuracy = mean(predictedclass == actualclass);

disp(predictionaccuracy)

%Run the analysis scripot for missed detect and false alarm