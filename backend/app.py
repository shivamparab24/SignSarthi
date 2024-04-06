from flask import Flask, request, jsonify, send_file, send_from_directory
from moviepy.editor import VideoFileClip, concatenate_videoclips
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

VIDEO_DIRECTORY = "concatenated"
app.config["VIDEO_DIRECTORY"] = VIDEO_DIRECTORY

UPLOAD_FOLDER = 'uploads'
CONCATENATED_FOLDER = 'concatenated'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['CONCATENATED_FOLDER'] = CONCATENATED_FOLDER

def find_videos_by_keywords(keywords):
    matching_videos = []
    for filename in os.listdir(app.config['UPLOAD_FOLDER']):
        if all(keyword.lower() in filename.lower() for keyword in keywords):
            matching_videos.append(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    return matching_videos

def concatenate_videos(video_paths):
    clips = [VideoFileClip(path) for path in video_paths]
    concatenated_clip = concatenate_videoclips(clips)
    concatenated_path = os.path.join(app.config['CONCATENATED_FOLDER'], 'concatenated.mp4')
    concatenated_clip.write_videofile(concatenated_path, codec="libx264")
    return concatenated_path

@app.route('/video')
def videos():
    return send_from_directory(app.config['VIDEO_DIRECTORY'], "concatenated.mp4")

@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/concatenate', methods=['POST'])
def concatenate():
    data = request.get_json()
    keywords = data.get('keywords',"")  # Assuming the keywords are sent in a JSON object
    #matching_videos = find_videos_by_keywords(keywords)
    #if not matching_videos:
    #    return jsonify({'error': 'No videos found for the provided keywords'}), 404
    #concatenated_path = concatenate_videos(matching_videos)
    concatenated_path = "http://127.0.0.1:5000/video"
    print(keywords)

    return "Successful!"

if __name__ == '__main__':
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    if not os.path.exists(CONCATENATED_FOLDER):
        os.makedirs(CONCATENATED_FOLDER)
    app.run(debug=True)