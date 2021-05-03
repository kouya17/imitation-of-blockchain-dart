import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;

//var port = '6565';

void main(List<String> args) {
  var output = querySelector('#output');
  var get_wallet_button = querySelector('#get_wallet_button');
  var get_blocks_button = querySelector('#get_blocks_button');
  var get_transactions_button = querySelector('#get_transactions_button');
  var post_transact_button = querySelector('#post_transact_button');
  var post_mine_button = querySelector('#post_mine_button');
  var input_address = querySelector('#address') as InputElement;
  var input_amount = querySelector('#amount') as InputElement;

  get_wallet_button?.onClick.listen((e) async {
    final responseBody = await get('/wallet');
    setOutput(JsonEncoder.withIndent('  ').convert(responseBody), output);
  });

  get_blocks_button?.onClick.listen((e) async {
    final responseBody = await get('/blocks');
    setOutput(JsonEncoder.withIndent('  ').convert(responseBody), output);
  });

  get_transactions_button?.onClick.listen((e) async {
    final responseBody = await get('/transactions');
    setOutput(JsonEncoder.withIndent('  ').convert(responseBody), output);
  });

  post_transact_button?.onClick.listen((e) async {
    final responseBody = await post(
        '/transact',
        jsonEncode({
          'recipient': input_address.value,
          'amount': double.parse(input_amount.value ?? '0')
        }));
    setOutput(JsonEncoder.withIndent('  ').convert(responseBody), output);
  });

  post_mine_button?.onClick.listen((e) async {
    final responseBody = await post('/mine', '');
    setOutput(JsonEncoder.withIndent('  ').convert(responseBody), output);
  });
}

void setOutput(String text, Element? output) {
  output?.text = text;
}

Future get(String path) async {
  return jsonDecode((await http.get(getBackEndUri(path))).body);
}

Future post(String path, String body) async {
  return jsonDecode((await http.post(getBackEndUri(path), body: body)).body);
}

Uri getBackEndUri(String path) {
  //return Uri.parse('http://localhost:' + port + path);
  return Uri.parse(path);
}
