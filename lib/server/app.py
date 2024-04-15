from flask import Flask, jsonify, request
from deepltranslator import DeeplTranslator

translator = DeeplTranslator()
app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the Deepl Translator API!"

@app.route('/translate', methods=['POST'])
def translate_text():
    # Récupérer le texte à traduire et les autres informations nécessaires
    # à partir de la requête POST
    data = request.get_json()
    text = data['text']
    source_lang = data['source_lang']
    target_lang = data['target_lang']

    # Utiliser la méthode translate de la classe DeeplTranslator pour traduire le texte
    translation = translator.translate(text, target_lang, source_lang)

    # Retourner le résultat de la traduction au format JSON
    return jsonify({'text': text, 'translation': translation, 'source_lang': source_lang, 'target_lang': target_lang})

if __name__ == '__main__':
    app.run(debug=True)
