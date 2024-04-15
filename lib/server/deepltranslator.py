#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import traceback
#import requests
import deepl
import os

class DeeplTranslator:

    def __init__(self):
        self.auth_key = os.environ.get('DEEPL_API_KEY')
        if not self.auth_key:
            print("DEEPL_API_KEY environment variable not found. Please set the environment variable with your DeepL API key.")
            exit(1)
        self.translator = deepl.Translator(self.auth_key, send_platform_info=False)

    def translate(self, text_to_translate, target_lang, source_lang):
        # Requests method
        """
        params = {
            'auth_key': self.auth_key,
            'text': text_to_translate,
            'target_lang': target_lang
        }
        
        try:
            response = requests.post(self.url, data=params)
            response.raise_for_status()  # Raise an exception for 4xx or 5xx response status codes
            source_lang = response.json()['translations'][0]['detected_source_language']
            translation = response.json()['translations'][0]['text']
            return source_lang, translation
        except Exception as e:
            traceback.print_exc()
            print(str(e))
            return None, None
        """

        # DeepL method
        try:
            result = self.translator.translate_text(text_to_translate, target_lang=target_lang, source_lang=source_lang, formality='less')
            translation = result.text
            return translation
        except Exception as e:
            traceback.print_exc()
            print(str(e))
            return None, None
        
