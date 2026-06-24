import 'package:flutter_test/flutter_test.dart';
import 'package:scanco/src/core/services/company_tag_mapper.dart';

void main() {
  group('CompanyTagMapper — exact ticker', () {
    test('KO → "Beverages"', () {
      final result = CompanyTagMapper.tag('KO', companyName: 'Coca-Cola Co');
      expect(result, isNotNull);
      expect(result!.tag, 'Beverages');
      expect(result.sector, 'Food');
    });

    test('PG → "Consumer Goods"', () {
      final result = CompanyTagMapper.tag(
        'PG',
        companyName: 'Procter & Gamble Co',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Consumer Goods');
    });

    test('AMD → "Tech • Microchips"', () {
      final result = CompanyTagMapper.tag(
        'AMD',
        companyName: 'Advanced Micro Devices Inc',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Tech • Microchips');
    });

    test('MSFT → "Software"', () {
      final result = CompanyTagMapper.tag(
        'MSFT',
        companyName: 'Microsoft Corp',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Software');
    });

    test('TSLA → "Electric Vehicles"', () {
      final result = CompanyTagMapper.tag('TSLA', companyName: 'Tesla Inc');
      expect(result, isNotNull);
      expect(result!.tag, 'Electric Vehicles');
    });

    test('COST → "Retail • Supermarkets"', () {
      final result = CompanyTagMapper.tag(
        'COST',
        companyName: 'Costco Wholesale Corp',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Retail • Supermarkets');
    });
  });

  group('CompanyTagMapper — case insensitivity', () {
    test('amd → AMD', () {
      final result = CompanyTagMapper.tag('amd');
      expect(result, isNotNull);
      expect(result!.tag, 'Tech • Microchips');
    });

    test('mSft → MSFT', () {
      final result = CompanyTagMapper.tag('mSft');
      expect(result, isNotNull);
      expect(result!.tag, 'Software');
    });
  });

  group('CompanyTagMapper — extended tickers', () {
    test('AAPL → "Tech • Smartphones"', () {
      expect(
        CompanyTagMapper.tag('AAPL')!.tag,
        'Tech • Smartphones',
      );
    });

    test('NVDA → "Semiconductors"', () {
      expect(CompanyTagMapper.tag('NVDA')!.tag, 'Semiconductors');
    });

    test('JPM → "Banking"', () {
      expect(CompanyTagMapper.tag('JPM')!.tag, 'Banking');
    });

    test('XOM → "Oil & Gas"', () {
      expect(CompanyTagMapper.tag('XOM')!.tag, 'Oil & Gas');
    });

    test('SPY → "S&P 500 Index"', () {
      expect(CompanyTagMapper.tag('SPY')!.tag, 'S&P 500 Index');
    });

    test('MCD → "Fast Food"', () {
      expect(CompanyTagMapper.tag('MCD')!.tag, 'Fast Food');
    });

    test('UNH → "Health Insurance"', () {
      expect(CompanyTagMapper.tag('UNH')!.tag, 'Health Insurance');
    });
  });

  group('CompanyTagMapper — composite tickers (suffixes)', () {
    test('BRK.B → not in map (BRK not in map), returns null', () {
      final result = CompanyTagMapper.tag('BRK.B');
      expect(result, isNull);
    });

    test('SBER.ME → SBER is in map (strip .ME)', () {
      final result = CompanyTagMapper.tag('SBER.ME');
      expect(result, isNotNull);
      expect(result!.tag, 'Banking');
    });
  });

  group('CompanyTagMapper — name-based fallback', () {
    test('Unknown ticker, name contains "Bank" → "Banking"', () {
      final result = CompanyTagMapper.tag(
        'UNKNOWN',
        companyName: 'First National Bank of America',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Banking');
      expect(result.sector, 'Financial');
    });

    test('Unknown ticker, name contains "Pharma" → "Pharmaceuticals"', () {
      final result = CompanyTagMapper.tag(
        'UNKNOWN',
        companyName: 'Global Pharma Solutions Ltd',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Pharmaceuticals');
    });

    test('Unknown ticker, name contains "Software" → "Software"', () {
      final result = CompanyTagMapper.tag(
        'UNKNOWN',
        companyName: 'Innovative Software Inc',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Software');
    });

    test('Unknown ticker, name contains "Electric Vehicle" → "Electric Vehicles"', () {
      final result = CompanyTagMapper.tag(
        'UNKNOWN',
        companyName: 'Fast Electric Vehicle Co',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Electric Vehicles');
    });

    test('Unknown ticker, name contains "Retail" → "Retail"', () {
      final result = CompanyTagMapper.tag(
        'UNKNOWN',
        companyName: 'Super Retail Group',
      );
      expect(result, isNotNull);
      expect(result!.tag, 'Retail');
    });

    test('Short name Inc → fallback "Corporation"', () {
      final result = CompanyTagMapper.tag('XZY', companyName: 'Sample Inc');
      expect(result, isNotNull);
      expect(result!.tag, 'Corporation');
    });
  });

  group('CompanyTagMapper — edge cases', () {
    test('Empty ticker → null', () {
      final result = CompanyTagMapper.tag('');
      expect(result, isNull);
    });

    test('Unknown ticker without name → null', () {
      final result = CompanyTagMapper.tag('ZZZZZ');
      expect(result, isNull);
    });

    test('Unknown ticker with empty name → null', () {
      final result = CompanyTagMapper.tag('ZZZZZ', companyName: '');
      expect(result, isNull);
    });

    test('hasTag — known ticker', () {
      expect(CompanyTagMapper.hasTag('AAPL'), isTrue);
      expect(CompanyTagMapper.hasTag('aapl'), isTrue);
    });

    test('hasTag — unknown ticker', () {
      expect(CompanyTagMapper.hasTag('ZZZZZ'), isFalse);
    });

    test('knownTickersCount > 100', () {
      expect(CompanyTagMapper.knownTickersCount, greaterThan(100));
    });
  });

  group('CompanyTagMapper — max tag length', () {
    test('All tags do not exceed 30 characters', () {
      final tickers = [
        'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA', 'AMD', 'INTC', 'TSLA',
        'KO', 'PEP', 'PG', 'JPM', 'BAC', 'V', 'MA', 'DIS', 'NFLX',
        'META', 'UNH', 'JNJ', 'PFE', 'MRK', 'ABBV', 'ABT', 'TMO',
        'XOM', 'CVX', 'BA', 'GE', 'CAT', 'HON', 'MCD', 'SBUX', 'NKE',
        'WMT', 'HD', 'COST', 'VZ', 'T', 'TMUS', 'SPY', 'QQQ', 'DIA',
        'MRNA', 'PLTR', 'SNAP', 'UBER', 'SQ', 'SHOP', 'NET', 'MSTR',
      ];

      for (final ticker in tickers) {
        final result = CompanyTagMapper.tag(ticker);
        expect(result, isNotNull, reason: 'No tag for $ticker');
        expect(
          result!.tag.length,
          lessThanOrEqualTo(30),
          reason: 'Tag "${result.tag}" for $ticker is ${result.tag.length} chars (max 30)',
        );
      }
    });
  });
}
