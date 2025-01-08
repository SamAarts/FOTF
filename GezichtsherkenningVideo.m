function GezichtsherkenningVideo(inputVideoFile, outputVideoFile)
    % Create a cascade detector object
    faceDetector = vision.CascadeObjectDetector();
    
    % Read a video frame and run the face detector
    videoReader = VideoReader(inputVideoFile);
    videoWriter = VideoWriter(outputVideoFile, 'MPEG-4');
    open(videoWriter);  % Open the video for writing
    
    % Read the first frame
    videoFrame = readFrame(videoReader);
    bbox = step(faceDetector, videoFrame);
    
    % Draw the returned bounding box around the detected face
    videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
    writeVideo(videoWriter, videoFrame); % Write the frame to output video
    
    % Convert the first box into a list of 4 points
    bboxPoints = bbox2points(bbox(1, :));
    points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);
    
    % Initialize point tracker
    pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
    points = points.Location;
    initialize(pointTracker, points, videoFrame);
    
    oldPoints = points;
    
    % Start video processing loop
    while hasFrame(videoReader)
        videoFrame = readFrame(videoReader);
        [points, isFound] = step(pointTracker, videoFrame);
        visiblePoints = points(isFound, :);
        oldInliers = oldPoints(isFound, :);
        
        if size(visiblePoints, 1) >= 2
            [xform, inlierIdx] = estimateGeometricTransform2D(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            oldInliers = oldInliers(inlierIdx, :);
            visiblePoints = visiblePoints(inlierIdx, :);
            
            bboxPoints = transformPointsForward(xform, bboxPoints);
            bboxPolygon = reshape(bboxPoints', 1, []);
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 2);
            videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');
            
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end
        
        % Write the processed frame to the output video
        writeVideo(videoWriter, videoFrame);
    end
    
    % Close the video writer object
    close(videoWriter);
end
