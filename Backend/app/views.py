# views.py

from flask import render_template
from flask import send_file, request
from app import app

import re
import json

from app.models import gen_text, SEQ_LEN, MODELS_LOADED, TOKS_LOADED

@app.route('/favicon.ico')
def favicon():
    return send_file('static/favicon.ico')

@app.route('/download')
def download():
    return send_file('static/Lyrisis.apk', as_attachment=True, attachment_filename="Lyrisis.apk")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/reference')
def reference():
    return render_template('reference.html')

# Now for the actual predictor api

@app.route('/predict', methods=['POST', 'GET'])
def predict():

    if request.method == 'GET':
        artist_name = str(request.args['artist'])
        temperature = float(request.args['temp'])
        seed = str(request.args['seed'])
        n_next_words = int(request.args['nwords'])

    elif request.method == 'POST':
        artist_name = str(request.form['artist'])
        temperature = float(request.form['temp'])
        seed = str(request.form['seed'])
        n_next_words = int(request.form['nwords'])

    print(artist_name, temperature, seed, n_next_words)

    # Preprocess the seed
    seed = re.sub('([*#@$%,?!()&*-./:[\]^_~\n])', r' \1 ', seed)

    out_text = gen_text(seed, n_next_words, SEQ_LEN, temperature, artist_name)

    # Note that the model considers '\n' as a separate word
    # But that's not so for us
    # So get another for every \n we got

    # TODO: will punctuations other than \n be counted as words?

    nl_count = 0
    for word in out_text.strip(' '):
        if word.__contains__('\n'):
            nl_count += 1

    if nl_count > 0:
        seed = seed + ' ' + out_text if not seed.endswith(' ') else seed + out_text
        out_text += ' ' + gen_text(seed, nl_count, SEQ_LEN, temperature, artist_name)

    out_words = {'words': out_text.split(' ')}

    return json.dumps(out_words)