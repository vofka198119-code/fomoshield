// Tiny in-memory symbol -> Finnhub security type cache, populated as
// SearchNotifier's results stream by. Lets Company Detail show an "ETF"
// badge for a symbol the user reached via Search, without a second API
// call — session-lifetime only, not persisted.
final Map<String, String> securityTypeCache = {};
