workingfolder='.\';
cd(workingfolder)

%Pull images from the train directory
%The train directory should have two subdirectories
%One subdirectory labeled "Noise", and the other "Signal"
imds = imageDatastore('.\train','FileExtensions',{'.bmp'},'IncludeSubfolders',true,'LabelSource','foldernames');

%Create a 90/10 split between training and validation
[imgsTrain,imgsValidation] = splitEachLabel(imds,0.9,'randomized');

%Show some of the images
numTrainImages = numel(imgsTrain.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    I = readimage(imgsTrain,idx(i));
    imshow(I)
end



%Load pore-trained Alexnet
net = alexnet;

%Set up transfer learning
layersTransfer = net.Layers(1:end-3);

numClasses = numel(categories(imgsTrain.Labels));
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];


options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',3, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',imgsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');

%Re-train the network
netTransfer = trainNetwork(imgsTrain,layers,options);


%Run a few of the validation images 
%and create a plot of results
[predictedclass,scores] = classify(netTransfer,imgsValidation);

idx = randperm(numel(imgsValidation.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(imgsValidation,idx(i));
    imshow(I)
    label = predictedclass(idx(i));
    strlabel = string(label);
    k = strfind(strlabel,'_');
    strlabel(k)=' ';
    title(strlabel);
end

%Calculate and display accuracy
actualclass = imgsValidation.Labels;
accuracy = mean(predictedclass == actualclass);

disp(accuracy)
