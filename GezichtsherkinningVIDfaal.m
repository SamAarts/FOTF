close all;clear;clc

the_Video = VideoReader('Test.mp4');
video_frame = readFrame(the_Video);

face_detector = vision.CascadeObjectDetector();
location_of_the_face = step(face_detector, video_frame);

detected_Frame = insertShape(video_frame, 'rectangle', location_of_the_face);

rectangle_to_point = bbox2points(location_of_the_face(1,:));
feature_points = detectMinEigenFeatures(rgb2gray(detected_Frame), 'ROI', location_of_the_face);

pointTracker = vision.PointTracker;

feature_points = feature_points.Location;
initialize(pointTracker, feature_points, detected_Frame)


left = 100;
bottom = 100;
width = size(detected_Frame, 2);
height = size(detected_Frame, 1);

video_player = vision.VideoPlayer('Position', [left bottom width height]);

previous_points = feature_points;

while hasFrame(the_Video)

    video_frame = readFrame(the_Video);
    
    [feature_points, isFound] = step(pointTracker,video_frame);

    new_points = feature_points(isFound,:);
    old_points = previous_points(isFound,:);

    if size(new_points,1) >= 2
        [transformed_rectangle, old_points, new_points] = estimateGeometricTransform(old_points, new_points, 'similarity', 'MaxDistance', 4);
        rectangle_to_Points = transformPointsForward(transformed_rectangle, rectangle_to_point);

        reshaped_rectangle = reshape(rectangle_to_Points',1, [])
        insertShape(video_frame, 'polygon', reshaped_rectangle, 'LineWidth',2);

        insertMarker(detected_Frame, new_points, '+', 'Color','White');

        previous_points = new_points;
        setPoints(pointTracker, previous_points);
    end

    step(video_player, detected_Frame);
    pause(1 / the_Video.FrameRate);

end

release(video_player)