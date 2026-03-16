import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class CryptoPrice {
  final double btc;
  final double eth;

  CryptoPrice({required this.btc, required this.eth});
}

final cryptoPriceProvider = FutureProvider<CryptoPrice>((ref) async {
  final dio = Dio();
  try {
    final btcResponse = await dio.get(
      'https://api.coingecko.com/api/v3/simple/price',
      queryParameters: {'ids': 'bitcoin', 'vs_currencies': 'usd'},
    );
    final ethResponse = await dio.get(
      'https://api.coingecko.com/api/v3/simple/price',
      queryParameters: {'ids': 'ethereum', 'vs_currencies': 'usd'},
    );

    final btcPrice = btcResponse.data['bitcoin']['usd'].toDouble();
    final ethPrice = ethResponse.data['ethereum']['usd'].toDouble();

    return CryptoPrice(btc: btcPrice, eth: ethPrice);
  } catch (e) {
    // Fallback prices if API fails
    return CryptoPrice(btc: 67000.0, eth: 3500.0);
  }
});
