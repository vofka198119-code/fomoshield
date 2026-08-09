part of '../portfolio_screen.dart';

// ---------------------------------------------------------------------------
// Portfolio Selector — always 3 fixed slots (matches maxPortfoliosProvider's
// premium cap of 3), not just one pill per portfolio that already exists.
// Slot 0 is free-tier's own portfolio (dark, white text) — always present,
// auto-created on first launch. Slots 1/2 are premium-only (gold outline,
// gold text, narrower): once created they're a real switchable portfolio
// tab exactly like slot 0; until then they're an invitation — "My
// Portfolio" for premium (tap creates it), or a locked "Create New
// Portfolio" for free (tap opens the premium upsell) — since real payment
// isn't wired up yet, this reuses the same promo-overlay-then-monetization-
// modal stub already used for premium-locked Home/Portfolio widgets.
// ---------------------------------------------------------------------------

class _PortfolioSelector extends ConsumerWidget {
  final List<Portfolio> portfolios;
  final String activeId;
  const _PortfolioSelector({required this.portfolios, required this.activeId});

  static const int _slotCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _slotCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i < portfolios.length) {
            final p = portfolios[i];
            return _portfolioTab(
              context,
              ref,
              key: ValueKey(p.id),
              portfolio: p,
              gold: i > 0,
            );
          }
          // Slot not created yet — only ever reachable for i > 0, since
          // slot 0 always has the auto-created default portfolio.
          return isPremium
              ? _emptyPremiumSlot(context, ref, key: ValueKey('empty_$i'))
              : _lockedSlot(context, ref, key: ValueKey('locked_$i'));
        },
      ),
    );
  }

  Widget _portfolioTab(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
    required Portfolio portfolio,
    required bool gold,
  }) {
    final isActive = portfolio.id == activeId;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              Icons.check,
              size: 14,
              color: gold ? dialBrassLight : Colors.white,
            ),
          ),
        Text(
          portfolio.name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: gold ? dialBrassLight : Colors.white,
          ),
        ),
      ],
    );

    return GestureDetector(
      key: key,
      onTap: () => _switchTo(context, ref, portfolio.id),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: gold ? 12 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [dialLight, dialDark],
            ),
            border: gold ? Border.all(color: dialBrassLight, width: 1) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _emptyPremiumSlot(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
  }) {
    return GestureDetector(
      key: key,
      onTap: () => _showCreatePortfolioDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [dialLight, dialDark],
          ),
          border: Border.all(color: dialBrassLight, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'My Portfolio',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: dialBrassLight,
          ),
        ),
      ),
    );
  }

  Widget _lockedSlot(BuildContext context, WidgetRef ref, {required Key key}) {
    return GestureDetector(
      key: key,
      onTap: () => showPremiumPromoOverlay(
        context: context,
        title: 'Additional portfolio',
        durationSeconds: 5,
        onComplete: () {
          if (context.mounted) showMonetizationModal(context, ref);
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [dialLight, dialDark],
          ),
          border: Border.all(
            color: dialBrassLight.withValues(alpha: 0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 12, color: dialBrassLight),
            const SizedBox(width: 5),
            Text(
              'Create New Portfolio',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dialBrassLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchTo(BuildContext context, WidgetRef ref, String id) async {
    if (id == activeId) return;
    ref.read(activePortfolioIdProvider.notifier).state = id;
    // Check ad counter on switch
    final tier = ref.read(subscriptionTierProvider);
    if (tier == SubscriptionTier.free) {
      final showAd = await ref
          .read(portfolioAdProvider.notifier)
          .incrementSwitch();
      if (showAd && context.mounted) {
        showPremiumPromoOverlay(
          context: context,
          title: 'Portfolio switched',
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      }
    }
  }

}
