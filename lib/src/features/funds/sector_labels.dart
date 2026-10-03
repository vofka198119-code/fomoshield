import '../../l10n/gen/app_localizations.dart';

// The canonical sector codes (English, matching fundService.js's
// ALLOWED_SECTORS exactly) are what's stored/sent to the backend —
// this only localizes the DISPLAY label, same split as fund tickers/names
// staying English while everything else in the UI is localized.
List<String> allowedSectorCodes(AppLocalizations l10n) => const [
  'Technology',
  'Healthcare',
  'Financials',
  'Consumer Discretionary',
  'Consumer Staples',
  'Energy',
  'Industrials',
  'Materials',
  'Utilities',
  'Real Estate',
  'Communication Services',
];

String sectorLabel(AppLocalizations l10n, String code) {
  switch (code) {
    case 'Technology':
      return l10n.etfSectorTechnology;
    case 'Healthcare':
      return l10n.etfSectorHealthcare;
    case 'Financials':
      return l10n.etfSectorFinancials;
    case 'Consumer Discretionary':
      return l10n.etfSectorConsumerDiscretionary;
    case 'Consumer Staples':
      return l10n.etfSectorConsumerStaples;
    case 'Energy':
      return l10n.etfSectorEnergy;
    case 'Industrials':
      return l10n.etfSectorIndustrials;
    case 'Materials':
      return l10n.etfSectorMaterials;
    case 'Utilities':
      return l10n.etfSectorUtilities;
    case 'Real Estate':
      return l10n.etfSectorRealEstate;
    case 'Communication Services':
      return l10n.etfSectorCommunicationServices;
    default:
      return code;
  }
}
