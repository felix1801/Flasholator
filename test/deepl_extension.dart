import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'dart:convert';



// https://www2.deepl.com/jsonrpc?client=chrome-extension,1.12.3

// headers = {
//     "User-Agent": "DeepLBrowserExtension/1.12.3 Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0",
//     "Accept": "*/*",
//     "Accept-Encoding": "gzip, deflate, br, zstd",
//     "Content-Type": "application/json; charset=utf-8",
//     "Authorization": "None",
//     "Content-Length": "170", // !\ Pas obligatoire mais bonne pratique : changer en fonction de la taille du body (en octets)
//     "Origin": "moz-extension://be821fe0-1fca-40a2-8c18-85b0dc4673e8",
//     "DNT": "1",
//     "Sec-Fetch-Dest": "empty",
//     "Sec-Fetch-Mode": "cors",
//     "Sec-Fetch-Site": "same-origin",
//     "Referer": "https://www.deepl.com/",
//     "Priority": "u=4"
//   };

// body = json.encode({
//     "jsonrpc": "2.0",
//     "method": "LMT_handle_texts",
//     "params": {
//         "texts": [{"text": "Chaud"}],
//         "lang": {
//             "target_lang": "EN",
//             "source_lang_user_selected": "FR",
//         },
//         "timestamp": 1725029564012 // !\ obligatoire : heure en milisecondes, à calculer
//     },
// });


// Créer un interceptor personnalisé
class LoggerInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    print('----- Request -----');
    print(request.toString());
    print(request.headers.toString());
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    print('----- Response -----');
    print('Code: ${response.statusCode}');
    if (response is Response) {
      print((response).body);
    }
    return response;
  }
}

// Fonction d'envoi de la requête avec l'interceptor
void sendRequest() async {
  // Créer un client HTTP avec un interceptor
  var client = InterceptedClient.build(interceptors: [LoggerInterceptor()]);

  var url = Uri.parse('https://www2.deepl.com/jsonrpc?client=chrome-extension,1.12.3');
  
  var body = json.encode({
    "jsonrpc": "2.0",
    "method": "LMT_handle_texts",
    "params": {
        "texts": [{"text": "Chaud"}],
        "lang": {
            "target_lang": "EN",
            "source_lang_user_selected": "FR",
        },
        "timestamp": DateTime.now().millisecondsSinceEpoch // !\ obligatoire : heure en milisecondes, à calculer
    },
});

  var encodedBody = utf8.encode(body);

  var headers = {
    "User-Agent": "DeepLBrowserExtension/1.12.3 Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br, zstd",
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "None",
    "Content-Length": encodedBody.length.toString(), // !\ Pas obligatoire mais bonne pratique : changer en fonction de la taille du body (en octets)
    "Origin": "moz-extension://be821fe0-1fca-40a2-8c18-85b0dc4673e8",
    "DNT": "1",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "same-origin",
    "Referer": "https://www.deepl.com/",
    "Priority": "u=4"
  };

  // Envoyer la requête
  var response = await client.post(url, headers: headers, body: utf8.decode(encodedBody));

  // Afficher la réponse pour vérifier
  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
}

void main() {
  sendRequest();
}