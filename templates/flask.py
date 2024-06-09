from flask import request, render_template, render_template_string, Flask, redirect, url_for
from flask_cors import CORS
import os.path

app = Flask(__name__)
app.config['Access-Control-Allow-Origin'] = '*'
CORS(app)

@app.route('/')
def index():
    return "Hello, World!"

def main():
    app.run(host='0.0.0.0', port=5173, debug=True, use_reloader=True)

if __name__ == "__main__":
    main()
