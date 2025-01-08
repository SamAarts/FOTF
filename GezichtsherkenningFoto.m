function GezichtsherkenningFoto(inputFile, outputFile)
    foto = imread(inputFile);
    [w, ~] = size(foto);

    if w > 320
        foto = imresize(foto, [320 NaN]);
    end

    faceDetector = vision.CascadeObjectDetector();
    face_Location = step(faceDetector, foto);

    foto = insertShape(foto, 'Rectangle', face_Location);
    imwrite(foto, outputFile);
end
