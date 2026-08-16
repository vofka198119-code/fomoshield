// ===========================================================================
// Metric Info Content — explanation text shown on MetricInfoScreen via the
// "?" next to a KEY METRICS row. One entry per metric id; a metric with no
// entry here just doesn't get a "?". Filled in incrementally as copy is
// provided by the user.
// ===========================================================================

class MetricInfoSection {
  final String? header;
  final String body;
  const MetricInfoSection({this.header, required this.body});
}

class MetricInfoContent {
  final String title;
  final String subtitle;
  final List<MetricInfoSection> sections;
  // Small "Educational & Academic Disclaimer" footer — only the 6 Financial
  // Score marker screens (Valuation, Financial Health, Growth Potential,
  // Efficiency, Historical Trend, Shareholder Returns) show it, not the
  // KEY METRICS screens (P/E, ROE, etc.) or the fs-score-legal screen.
  final bool showAcademicDisclaimer;
  // Full StressTestVerdictDisclaimer footer — every Psychology Meter
  // marker screen (psychology-discipline/panic/patience/strategy/
  // diversification, investor-score) shows this instead, matching the
  // same mandatory disclaimer used on Session Complete / the per-marker
  // "More" screen / the Psychology Meter detail screen — see
  // stress_test_verdict_disclaimer.dart. Mutually exclusive with
  // showAcademicDisclaimer in practice (company-detail markers vs.
  // stress-test markers), but not enforced — don't set both.
  final bool showStressTestDisclaimer;
  const MetricInfoContent({
    required this.title,
    required this.subtitle,
    required this.sections,
    this.showAcademicDisclaimer = false,
    this.showStressTestDisclaimer = false,
  });
}

// Maps a KEY METRICS row's label (e.g. 'P/E') to the registry id below —
// separate from the id itself so several labels could share one entry if
// that's ever needed.
const Map<String, String> metricInfoIdByLabel = {
  'P/E': 'pe',
  'Dividend Yield': 'dividend-yield',
  'Net Margin': 'net-margin',
  'Operating Margin': 'operating-margin',
  'Gross Margin': 'gross-margin',
  'ROE': 'roe',
  // Financial Score's 6 markers (financial_score_widget.dart). The "?"
  // icon shows for all of them regardless of registry content below —
  // one without an entry just opens a blank screen until its text is added.
  'Valuation': 'valuation',
  'Financial Health': 'financial-health',
  'Growth Potential': 'growth-potential',
  'Efficiency': 'efficiency',
  'Historical Trend': 'historical-trend',
  'Shareholder Returns': 'capital-return',
};

const Map<String, MetricInfoContent> metricInfoRegistry = {
  'pe': MetricInfoContent(
    title: 'P/E',
    subtitle: 'Price-to-Earnings Ratio',
    sections: [
      MetricInfoSection(
        header: 'What is P/E?',
        body:
            'The Price-to-Earnings Ratio (P/E) compares a company\'s stock '
            'price to the amount of profit it earns.\n\n'
            'In simple terms: P/E shows how much investors are willing to '
            'pay today for every \$1 of the company\'s annual earnings. It '
            'is one of the most widely used valuation metrics in the stock '
            'market.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nP/E = Share Price ÷ Earnings Per Share (EPS)\n\n'
            'Example\nShare Price = \$100\nEarnings Per Share = \$5\n'
            'P/E = 100 ÷ 5 = 20\n\n'
            'This means investors are currently paying \$20 for every \$1 '
            'of annual profit.',
      ),
      MetricInfoSection(
        header: 'What does it tell you?',
        body:
            'P/E helps answer one important question: "Is this company '
            'expensive or cheap compared to its earnings?"\n\n'
            'Generally:\n'
            '• Lower P/E = lower valuation\n'
            '• Higher P/E = higher valuation\n\n'
            'However, a low P/E is not automatically good, and a high P/E '
            'is not automatically bad. Context always matters.',
      ),
      MetricInfoSection(
        header: 'What is considered a good P/E?',
        body:
            'There is no perfect number, because every industry is '
            'different.\n\n'
            'Below 10 — Often considered very cheap. Possible reasons: '
            'market pessimism, declining business, temporary problems, or '
            'a hidden opportunity. Requires careful research.\n\n'
            '10–20 — Often considered a reasonable valuation for mature '
            'companies. Common among stable businesses such as consumer '
            'goods, banks, and industrial companies.\n\n'
            '20–30 — Investors expect future earnings growth, a strong '
            'competitive position, and a reliable business model. The '
            'company is becoming more expensive.\n\n'
            'Above 30 — The market expects significant future growth. '
            'Common among technology companies, fast-growing businesses, '
            'and innovative industries. These companies can perform very '
            'well — but they also carry higher expectations.',
      ),
      MetricInfoSection(
        header: 'Why can a high P/E be completely normal?',
        body:
            'Imagine two companies.\n\n'
            'Company A — Profit grows 2% per year, P/E = 12\n'
            'Company B — Profit grows 35% per year, P/E = 40\n\n'
            'At first glance, Company B looks very expensive. But if its '
            'profits continue growing rapidly, today\'s high valuation may '
            'become reasonable over time. Investors are paying not only '
            'for today\'s earnings — but also for tomorrow\'s potential.',
      ),
      MetricInfoSection(
        header: 'Why can a low P/E be dangerous?',
        body:
            'A low P/E may indicate that investors expect problems. '
            'Possible reasons include: falling sales, declining profits, '
            'large debt, loss of market share, legal issues, or poor '
            'management.\n\n'
            'Sometimes the market is simply reacting to risks that are not '
            'immediately obvious. This is known as a Value Trap — a stock '
            'that appears cheap but continues to perform poorly.',
      ),
      MetricInfoSection(
        header: 'What if the P/E is negative?',
        body:
            'A negative P/E means the company reported a loss instead of a '
            'profit. This does not necessarily mean the company is '
            'failing.\n\n'
            'Possible reasons include: heavy investment in future growth, '
            'building new factories, expanding into new markets, acquiring '
            'another company, a temporary economic downturn, or one-time '
            'accounting expenses.\n\n'
            'Many successful companies have experienced periods of '
            'negative earnings before returning to profitability.',
      ),
      MetricInfoSection(
        header: 'What is "Hype"?',
        body:
            'Sometimes investors become extremely optimistic about a '
            'company. The stock price rises much faster than the '
            'company\'s actual earnings, so the P/E ratio becomes very '
            'high.\n\n'
            'This often happens when investors expect revolutionary '
            'technology, Artificial Intelligence growth, new breakthrough '
            'products, or massive future expansion. A high P/E driven by '
            'excitement is often called market hype.\n\n'
            'If the company fails to meet those high expectations, the '
            'stock price can fall sharply — even if the business remains '
            'healthy.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Buying only because the P/E is low.\n'
            '• Avoiding every company with a high P/E.\n'
            '• Comparing companies from completely different industries.\n'
            '• Ignoring profit growth.\n'
            '• Ignoring debt levels.\n'
            '• Making investment decisions based on a single metric.',
      ),
      MetricInfoSection(
        header: 'P/E has limitations',
        body:
            'P/E works best for companies that consistently earn profits. '
            'It is less useful for startups, companies with temporary '
            'losses, businesses with highly cyclical earnings, or firms '
            'experiencing major restructuring.\n\n'
            'For these companies, investors often rely on additional '
            'valuation metrics.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'P/E should never be viewed alone. Combine it with: Revenue '
            'Growth, Net Margin, Operating Margin, ROE, Debt Levels, Free '
            'Cash Flow, and Dividend Yield.\n\n'
            'Looking at several metrics together provides a much clearer '
            'picture of a company\'s financial health.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine two apartment buildings.\n\n'
            'Building A — Price: \$500,000, Annual rental income: '
            '\$50,000\n'
            'Building B — Price: \$1,000,000, Annual rental income: '
            '\$50,000\n\n'
            'Building A appears much cheaper. But if Building B is located '
            'in the center of a rapidly growing city where rental income '
            'is expected to double in a few years, the higher price may be '
            'justified.\n\n'
            'Stocks work in a similar way.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'P/E measures how much investors are paying for each dollar of '
            'a company\'s earnings. It is an excellent starting point for '
            'evaluating a stock — but it should never be used as the only '
            'factor when making an investment decision.',
      ),
    ],
  ),
  'dividend-yield': MetricInfoContent(
    title: 'Dividend Yield',
    subtitle: 'Annual Dividend Income vs. Share Price',
    sections: [
      MetricInfoSection(
        header: 'What is Dividend Yield?',
        body:
            'Dividend Yield shows how much cash a company pays its '
            'shareholders each year relative to the current stock '
            'price.\n\n'
            'In simple terms: Dividend Yield tells you how much annual '
            'income you receive from dividends for every \$100 invested in '
            'the stock. It is one of the most important metrics for income '
            'investors.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nDividend Yield = Annual Dividend per Share ÷ Share '
            'Price × 100%\n\n'
            'Example\nAnnual Dividend = \$2.40\nShare Price = \$100\n'
            'Dividend Yield = 2.4%\n\n'
            'This means that for every \$100 invested, you receive '
            'approximately \$2.40 per year in dividends (before taxes).',
      ),
      MetricInfoSection(
        header: 'What does it tell you?',
        body:
            'Dividend Yield measures the income potential of a stock.\n\n'
            'Generally:\n'
            '• Higher Yield = Higher dividend income\n'
            '• Lower Yield = Lower dividend income\n\n'
            'However, a higher dividend yield is not always better.',
      ),
      MetricInfoSection(
        header: 'What is considered a good Dividend Yield?',
        body:
            'There is no universal "best" number.\n\n'
            '0% — The company pays no dividend. Common for growth '
            'companies, startups, and many technology companies. Instead '
            'of paying shareholders, these businesses reinvest profits to '
            'grow faster.\n\n'
            '1%–2% — A relatively small dividend. Often seen in companies '
            'focused on long-term growth while still rewarding '
            'shareholders.\n\n'
            '2%–4% — Generally considered a healthy and sustainable range. '
            'Many high-quality companies fall into this category.\n\n'
            '4%–6% — A relatively high dividend. Can be attractive, but '
            'investors should check whether the company can continue '
            'paying it.\n\n'
            'Above 6% — Requires extra attention. Sometimes the dividend '
            'is genuinely generous. Sometimes the stock price has fallen '
            'sharply, making the yield appear unusually high. This can be '
            'a warning sign rather than a bargain.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high Dividend Yield always good?',
        body:
            'Dividend Yield increases whenever dividends increase, or the '
            'stock price falls.\n\n'
            'Imagine this example.\n\n'
            'Yesterday — Price = \$100, Dividend = \$4, Yield = 4%\n'
            'Today — Price falls to \$50, Dividend stays \$4, Yield '
            'becomes 8%\n\n'
            'The dividend hasn\'t improved. The stock simply became much '
            'cheaper. Investors may be worried about the company\'s '
            'future.',
      ),
      MetricInfoSection(
        header:
            'Can a company have a 0% Dividend Yield and still be '
            'excellent?',
        body:
            'Absolutely. Many successful companies choose not to pay '
            'dividends. Instead, they use their profits to: develop new '
            'products, expand internationally, build new factories, '
            'acquire competitors, or invest in research and '
            'innovation.\n\n'
            'If those investments generate higher future profits, '
            'shareholders may benefit through rising stock prices instead '
            'of dividend payments.',
      ),
      MetricInfoSection(
        header: 'Can Dividend Yield decrease?',
        body:
            'Yes. Reasons include: the stock price rises faster than '
            'dividends, the company reduces its dividend, or the company '
            'temporarily suspends dividend payments.\n\n'
            'A lower yield does not automatically indicate a weaker '
            'company.',
      ),
      MetricInfoSection(
        header: 'Can Dividend Yield increase?',
        body:
            'Yes. Possible reasons: the company raises its dividend, the '
            'stock price declines, or both occur simultaneously.\n\n'
            'This is why investors should always determine why the yield '
            'changed.',
      ),
      MetricInfoSection(
        header: 'What is a Dividend Cut?',
        body:
            'A Dividend Cut occurs when a company reduces the amount of '
            'money it pays shareholders. Companies may cut dividends '
            'because they need cash for: paying debt, surviving an '
            'economic downturn, funding major investments, or protecting '
            'the business during difficult periods.\n\n'
            'A dividend cut is not always a sign of failure. Sometimes it '
            'is a responsible financial decision that strengthens the '
            'company over the long term.',
      ),
      MetricInfoSection(
        header: 'Why do some companies never pay dividends?',
        body:
            'Many growth companies believe that every dollar earned can '
            'generate even greater returns if reinvested into the '
            'business. For example: expanding into new markets, hiring '
            'more employees, developing new technology, or increasing '
            'production capacity.\n\n'
            'In these cases, investors expect capital appreciation instead '
            'of dividend income.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Buying the stock with the highest Dividend Yield.\n'
            '• Assuming dividends are guaranteed forever.\n'
            '• Ignoring the company\'s earnings and cash flow.\n'
            '• Comparing dividend yields across completely different '
            'industries.\n'
            '• Focusing only on income while ignoring business quality.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'Dividend Yield becomes much more meaningful when combined '
            'with: Dividend Payout Ratio, Earnings Growth, Free Cash Flow, '
            'P/E Ratio, Net Margin, and Debt Levels.\n\n'
            'These metrics help determine whether the dividend is '
            'sustainable.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine buying a rental apartment.\n\n'
            'Apartment A costs \$200,000 and generates \$6,000 per year in '
            'rent. Rental Yield = 3%\n\n'
            'Apartment B costs \$200,000 and generates \$12,000 per year. '
            'Rental Yield = 6%\n\n'
            'Apartment B looks much more attractive. But if the building '
            'requires expensive repairs or tenants are leaving, the higher '
            'rental yield may come with higher risk.\n\n'
            'Dividend investing works much the same way.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Dividend Yield measures the annual dividend income you '
            'receive relative to the current stock price. A higher yield '
            'can be attractive, but the quality and sustainability of '
            'those dividends are far more important than the percentage '
            'itself.',
      ),
    ],
  ),
  'net-margin': MetricInfoContent(
    title: 'Net Margin',
    subtitle: 'Profit Kept After All Expenses',
    sections: [
      MetricInfoSection(
        header: 'What is Net Margin?',
        body:
            'Net Margin measures how much profit a company keeps after '
            'paying all of its expenses. These expenses include: cost of '
            'products, employee salaries, rent, taxes, interest on debt, '
            'operating expenses, and all other business costs.\n\n'
            'In simple terms: Net Margin shows how much money the company '
            'actually keeps from every dollar of sales. It is often '
            'considered one of the best indicators of a company\'s overall '
            'profitability.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nNet Margin = Net Income ÷ Revenue × 100%\n\n'
            'Example\nRevenue = \$100 million\nNet Income = \$20 '
            'million\nNet Margin = 20%\n\n'
            'This means the company keeps \$20 in profit for every \$100 '
            'of sales.',
      ),
      MetricInfoSection(
        header: 'What does it tell you?',
        body:
            'Net Margin measures how efficiently a company converts '
            'revenue into actual profit.\n\n'
            'Generally:\n'
            '• Higher Margin = More profitable business\n'
            '• Lower Margin = Less profitable business\n\n'
            'Companies with strong Net Margins usually have: efficient '
            'operations, strong pricing power, good cost control, and '
            'healthy business models.',
      ),
      MetricInfoSection(
        header: 'What is considered a good Net Margin?',
        body:
            'There is no universal standard because industries are very '
            'different.\n\n'
            'Below 5% — Usually considered a low profit margin. Common in '
            'businesses with intense competition or thin margins, e.g. '
            'grocery stores, airlines, retail chains.\n\n'
            '5%–10% — Healthy for many traditional businesses.\n\n'
            '10%–20% — Very good profitability. Many successful companies '
            'consistently operate in this range.\n\n'
            'Above 20% — Excellent profitability. Often found in companies '
            'with strong brands, software businesses, luxury products, or '
            'high-value technology.\n\n'
            'Above 30% — Exceptional. Usually indicates an outstanding '
            'business model or a company with significant competitive '
            'advantages.',
      ),
      MetricInfoSection(
        header: 'Why is a high Net Margin important?',
        body:
            'A company with a high Net Margin has more flexibility. It '
            'can: invest in growth, increase dividends, buy back shares, '
            'survive difficult economic periods, or continue investing '
            'during recessions.\n\n'
            'Higher profitability often means a stronger and more '
            'resilient business.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low Net Margin always bad?',
        body:
            'Some industries naturally operate with low margins. For '
            'example, a supermarket may earn only 2% Net Margin but sell '
            'billions of dollars of products every year. Small profits on '
            'enormous sales can still produce substantial earnings.\n\n'
            'This is why Net Margin should always be compared with '
            'companies in the same industry.',
      ),
      MetricInfoSection(
        header: 'Can Net Margin be negative?',
        body:
            'Yes. A negative Net Margin means the company lost money '
            'during the reporting period. However, this does not '
            'automatically mean the business is failing.\n\n'
            'Possible reasons include: heavy investments, economic '
            'recession, one-time legal expenses, factory construction, '
            'acquisitions, temporary restructuring, or currency '
            'losses.\n\n'
            'Many successful companies have experienced temporary negative '
            'margins before returning to profitability.',
      ),
      MetricInfoSection(
        header: 'What causes Net Margin to improve?',
        body:
            'Net Margin usually increases when a company: sells more '
            'products, raises prices, reduces costs, improves efficiency, '
            'pays less interest, or lowers operating expenses.\n\n'
            'Consistently improving margins often indicate excellent '
            'management.',
      ),
      MetricInfoSection(
        header: 'What causes Net Margin to decline?',
        body:
            'Profit margins may shrink because of: rising production '
            'costs, higher wages, inflation, increased competition, '
            'falling sales, higher interest rates, or unexpected '
            'expenses.\n\n'
            'A temporary decline is normal. A long-term downward trend '
            'deserves closer attention.',
      ),
      MetricInfoSection(
        header: 'Why is comparing industries important?',
        body:
            'Different industries have completely different business '
            'models. For example, a supermarket may have a 2% Net Margin '
            'and still be an excellent business, while a software company '
            'with a 2% Net Margin would likely have serious profitability '
            'issues.\n\n'
            'Always compare companies with their direct competitors.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Assuming every company should have the same Net Margin.\n'
            '• Comparing technology companies with retailers.\n'
            '• Ignoring long-term trends.\n'
            '• Looking at only one year\'s results.\n'
            '• Ignoring why margins changed.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'Net Margin becomes even more useful when combined with: '
            'Gross Margin, Operating Margin, ROE, Revenue Growth, Free '
            'Cash Flow, P/E Ratio, and Debt Levels.\n\n'
            'Together, these metrics provide a much more complete picture '
            'of a company\'s financial health.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine two restaurants.\n\n'
            'Restaurant A earns \$1,000,000 in annual sales but keeps only '
            '\$20,000 in profit. Net Margin = 2%\n\n'
            'Restaurant B earns the same \$1,000,000 but keeps \$200,000. '
            'Net Margin = 20%\n\n'
            'Both restaurants generate the same revenue, but Restaurant B '
            'is far more efficient and profitable. That\'s exactly what '
            'Net Margin helps investors understand.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Net Margin measures how much profit a company keeps after '
            'paying all expenses. Higher margins generally indicate a '
            'stronger, more efficient, and more financially healthy '
            'business, but comparisons should always be made within the '
            'same industry.',
      ),
    ],
  ),
  'operating-margin': MetricInfoContent(
    title: 'Operating Margin',
    subtitle: 'Core Business Profit Before Interest and Taxes',
    sections: [
      MetricInfoSection(
        header: 'What is Operating Margin?',
        body:
            'Operating Margin measures how much profit a company earns '
            'from its core business operations before paying interest on '
            'debt and taxes. Unlike Net Margin, Operating Margin focuses '
            'only on how efficiently the business itself is run.\n\n'
            'In simple terms: Operating Margin shows how much money the '
            'company keeps from every dollar of sales before financing '
            'costs and taxes. Many professional investors consider this '
            'one of the best measures of management efficiency.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nOperating Margin = Operating Income ÷ Revenue × '
            '100%\n\n'
            'Example\nRevenue = \$100 million\nOperating Income = \$25 '
            'million\nOperating Margin = 25%\n\n'
            'This means that after paying for all operating expenses, the '
            'company keeps \$25 for every \$100 of sales, before interest '
            'and taxes.',
      ),
      MetricInfoSection(
        header: 'What does it tell you?',
        body:
            'Operating Margin measures how profitable the company\'s core '
            'business really is. It answers questions like: is management '
            'controlling costs? Is the business efficient? Can the '
            'company generate healthy profits from its everyday '
            'operations?\n\n'
            'A strong Operating Margin usually indicates a well-managed '
            'company.',
      ),
      MetricInfoSection(
        header: 'What is Operating Income?',
        body:
            'Operating Income is the profit remaining after paying for: '
            'cost of goods sold (COGS), employee salaries, rent, '
            'marketing, research & development, administrative expenses, '
            'and other operating costs.\n\n'
            'It does not include: interest payments, income taxes, or '
            'one-time extraordinary gains or losses.\n\n'
            'This makes Operating Margin a cleaner measure of business '
            'performance.',
      ),
      MetricInfoSection(
        header: 'What is considered a good Operating Margin?',
        body:
            'Different industries have different standards.\n\n'
            'Below 5% — Generally considered low. Common in businesses '
            'with intense competition.\n\n'
            '5%–10% — Healthy for many traditional companies.\n\n'
            '10%–20% — Strong operating performance. Many successful '
            'businesses consistently achieve margins in this range.\n\n'
            'Above 20% — Excellent. Often indicates strong pricing power, '
            'efficient management, or competitive advantages.\n\n'
            'Above 30% — Outstanding. Usually found in software companies, '
            'luxury brands, or businesses with exceptionally efficient '
            'operations.',
      ),
      MetricInfoSection(
        header: 'Why is Operating Margin important?',
        body:
            'Unlike Net Margin, Operating Margin removes factors that '
            'management doesn\'t fully control, such as tax rates, '
            'interest expenses, and debt structure. This allows investors '
            'to evaluate the quality of the company\'s actual business '
            'operations.\n\n'
            'Two companies may have different Net Margins simply because '
            'one has more debt. Operating Margin helps remove that '
            'distortion.',
      ),
      MetricInfoSection(
        header: 'Why can Operating Margin be low?',
        body:
            'A lower Operating Margin does not automatically mean a weak '
            'company. Possible reasons include: heavy investment in '
            'growth, launching new products, expanding into new markets, '
            'higher marketing spending, rising labor costs, or temporary '
            'inflation.\n\n'
            'Sometimes these investments lead to much stronger profits in '
            'the future.',
      ),
      MetricInfoSection(
        header: 'Can Operating Margin be negative?',
        body:
            'Yes. A negative Operating Margin means the company\'s core '
            'business is currently losing money before even paying '
            'interest or taxes.\n\n'
            'Possible reasons include: weak sales, high production costs, '
            'poor cost control, major expansion, economic downturn, or '
            'temporary restructuring.\n\n'
            'A single negative quarter is not necessarily alarming. '
            'However, consistently negative Operating Margins deserve '
            'careful investigation.',
      ),
      MetricInfoSection(
        header: 'Why do investors like stable Operating Margins?',
        body:
            'A company with stable or improving Operating Margins often '
            'demonstrates: strong management, consistent pricing power, '
            'good cost control, and sustainable competitive advantages.\n\n'
            'Long-term stability is often more valuable than one '
            'exceptionally high result.',
      ),
      MetricInfoSection(
        header: 'Why should you compare companies in the same industry?',
        body:
            'Operating Margins vary dramatically between industries. For '
            'example, a supermarket may operate with a 4% Operating '
            'Margin and still be an excellent business, while a software '
            'company with a 4% Operating Margin would likely have serious '
            'profitability issues.\n\n'
            'Industry comparisons are essential.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Confusing Operating Margin with Net Margin.\n'
            '• Comparing companies from different industries.\n'
            '• Ignoring long-term trends.\n'
            '• Assuming one unusually high year represents normal '
            'performance.\n'
            '• Looking only at one financial metric.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'Operating Margin becomes much more powerful when analyzed '
            'alongside: Gross Margin, Net Margin, Revenue Growth, ROE, '
            'Free Cash Flow, Debt Levels, and P/E Ratio.\n\n'
            'Together, these metrics provide a comprehensive view of '
            'business quality.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine two delivery companies. Both generate \$100 million '
            'in revenue.\n\n'
            'Company A spends \$85 million operating its business. '
            'Operating Margin = 15%\n\n'
            'Company B spends only \$70 million. Operating Margin = '
            '30%\n\n'
            'Even before paying taxes or interest, Company B is running a '
            'much more efficient business. That efficiency often leads to '
            'stronger long-term performance.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Operating Margin measures how profitable a company\'s core '
            'business is before interest and taxes. A higher Operating '
            'Margin generally indicates better operational efficiency, '
            'stronger cost control, and a healthier underlying business '
            'model.',
      ),
    ],
  ),
  'gross-margin': MetricInfoContent(
    title: 'Gross Margin',
    subtitle: 'Profit After Direct Production Costs',
    sections: [
      MetricInfoSection(
        header: 'What is Gross Margin?',
        body:
            'Gross Margin measures how much money a company keeps after '
            'paying only the direct costs of producing its products or '
            'services. These direct costs are known as Cost of Goods Sold '
            '(COGS).\n\n'
            'In simple terms: Gross Margin shows how profitable a '
            'company\'s products are before paying for salaries, '
            'marketing, rent, taxes, interest, and other operating '
            'expenses. It is one of the first indicators of a company\'s '
            'pricing power and production efficiency.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nGross Margin = (Revenue − Cost of Goods Sold) ÷ '
            'Revenue × 100%\n\n'
            'Example\nRevenue = \$100 million\nCost of Goods Sold = \$60 '
            'million\nGross Profit = \$40 million\nGross Margin = 40%\n\n'
            'This means the company keeps \$40 from every \$100 of sales '
            'before paying any operating expenses.',
      ),
      MetricInfoSection(
        header: 'What is Cost of Goods Sold (COGS)?',
        body:
            'COGS includes the direct costs required to produce a product '
            'or provide a service. Examples include: raw materials, '
            'manufacturing costs, factory labor, packaging, shipping to '
            'warehouses, and production equipment directly used to make '
            'products.\n\n'
            'COGS does not include: office salaries, advertising, '
            'research & development, taxes, interest payments, or '
            'administrative expenses.',
      ),
      MetricInfoSection(
        header: 'What does it tell you?',
        body:
            'Gross Margin answers one simple question: "How profitable is '
            'the product itself?"\n\n'
            'A high Gross Margin usually means the company can produce '
            'its products at a relatively low cost compared to the '
            'selling price.',
      ),
      MetricInfoSection(
        header: 'What is considered a good Gross Margin?',
        body:
            'The answer depends on the industry.\n\n'
            'Below 20% — Typically found in industries with intense price '
            'competition, e.g. grocery stores, food wholesalers, fuel '
            'distributors.\n\n'
            '20%–40% — Healthy for many traditional manufacturers.\n\n'
            '40%–60% — Strong profitability. Common among companies with '
            'valuable brands or premium products.\n\n'
            'Above 60% — Excellent. Frequently seen in software '
            'companies, luxury brands, pharmaceutical companies, and '
            'technology businesses.\n\n'
            'Above 80% — Exceptional. Usually indicates that the product '
            'costs very little to produce while customers are willing to '
            'pay a premium price.',
      ),
      MetricInfoSection(
        header: 'Why is a high Gross Margin important?',
        body:
            'A company with a high Gross Margin has more money available '
            'to pay for: marketing, employee salaries, research & '
            'development, expansion, debt payments, or dividends.\n\n'
            'High Gross Margins give businesses greater flexibility '
            'during difficult economic periods.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low Gross Margin always bad?',
        body:
            'Some industries naturally have low Gross Margins. For '
            'example, a supermarket may earn only 15% Gross Margin, but '
            'because it sells millions of products every day, it can '
            'still generate significant profits.\n\n'
            'Business models matter. Always compare companies within the '
            'same industry.',
      ),
      MetricInfoSection(
        header: 'Can Gross Margin decrease?',
        body:
            'Yes. Common reasons include: rising material costs, higher '
            'wages, increased shipping costs, inflation, discounts '
            'offered to customers, stronger competition, or supply chain '
            'disruptions.\n\n'
            'A declining Gross Margin often signals that production is '
            'becoming more expensive or pricing power is weakening.',
      ),
      MetricInfoSection(
        header: 'Can Gross Margin increase?',
        body:
            'Absolutely. Possible reasons include: higher product prices, '
            'lower production costs, better supplier contracts, improved '
            'manufacturing efficiency, selling more premium products, or '
            'economies of scale.\n\n'
            'Improving Gross Margins often indicate a strengthening '
            'business.',
      ),
      MetricInfoSection(
        header: 'Why do investors monitor Gross Margin trends?',
        body:
            'A single year\'s Gross Margin tells only part of the story. '
            'What\'s more important is whether the margin is increasing, '
            'stable, or declining.\n\n'
            'A company with steadily improving Gross Margins is often '
            'becoming more competitive and more efficient.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Thinking Gross Margin equals overall profit.\n'
            '• Comparing completely different industries.\n'
            '• Ignoring changes over time.\n'
            '• Looking only at one year\'s results.\n'
            '• Forgetting that operating expenses still need to be paid.',
      ),
      MetricInfoSection(
        header:
            'How is Gross Margin different from Operating Margin and '
            'Net Margin?',
        body:
            'Think of profitability as three stages.\n\n'
            'Gross Margin — How profitable is the product itself?\n\n'
            'Operating Margin — How profitable is the entire business '
            'operation?\n\n'
            'Net Margin — How much profit remains after absolutely '
            'everything has been paid?\n\n'
            'These three margins together tell the complete story of a '
            'company\'s profitability.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'Gross Margin becomes much more valuable when combined with: '
            'Operating Margin, Net Margin, Revenue Growth, ROE, Free Cash '
            'Flow, and P/E Ratio.\n\n'
            'Together they help investors understand where a company\'s '
            'profits are being earned — and where they are being spent.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine a bakery sells a cake for \$100. The ingredients '
            'cost \$35.\n\n'
            'Gross Profit = \$65\nGross Margin = 65%\n\n'
            'However, the bakery still has to pay: employee wages, rent, '
            'electricity, advertising, and taxes. Only after paying those '
            'expenses does the business know its true profit.\n\n'
            'Gross Margin simply measures how profitable the cake itself '
            'is before all those additional costs.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Gross Margin measures how much money a company keeps after '
            'paying the direct costs of producing its products or '
            'services. A higher Gross Margin generally indicates stronger '
            'pricing power, better production efficiency, and greater '
            'financial flexibility — but it should always be compared '
            'with companies in the same industry.',
      ),
    ],
  ),
  'roe': MetricInfoContent(
    title: 'ROE',
    subtitle: 'Return on Equity',
    sections: [
      MetricInfoSection(
        header: 'What is ROE?',
        body:
            'Return on Equity (ROE) measures how efficiently a company '
            'generates profit using the money invested by its '
            'shareholders.\n\n'
            'In simple terms: ROE shows how much profit the company earns '
            'for every \$1 of shareholders\' equity. It is one of the '
            'most important indicators of management efficiency and '
            'business quality.',
      ),
      MetricInfoSection(
        header: 'How is it calculated?',
        body:
            'Formula\nROE = Net Income ÷ Shareholders\' Equity × 100%\n\n'
            'Example\nNet Income = \$20 million\nShareholders\' Equity = '
            '\$100 million\nROE = 20%\n\n'
            'This means the company generated 20 cents of profit for '
            'every \$1 invested by shareholders.',
      ),
      MetricInfoSection(
        header: 'What is Shareholders\' Equity?',
        body:
            'Shareholders\' Equity represents the value that belongs to '
            'the company\'s owners after all debts have been paid. It is '
            'calculated as:\n\n'
            'Assets − Liabilities = Shareholders\' Equity\n\n'
            'Think of it as the company\'s net worth. If the business '
            'sold all of its assets and paid every debt, whatever '
            'remained would belong to the shareholders.',
      ),
      MetricInfoSection(
        header: 'What does ROE tell you?',
        body:
            'ROE measures how effectively management uses shareholders\' '
            'money. A higher ROE generally means the company is producing '
            'more profit without requiring large amounts of additional '
            'investment.\n\n'
            'Companies with consistently high ROE often have: strong '
            'business models, efficient management, competitive '
            'advantages, and high profitability.',
      ),
      MetricInfoSection(
        header: 'What is considered a good ROE?',
        body:
            'The answer depends on the industry, but general guidelines '
            'are:\n\n'
            'Below 5% — Usually considered weak. The company is '
            'generating relatively little profit from shareholders\' '
            'capital.\n\n'
            '5%–10% — Acceptable. Common among slower-growing or highly '
            'competitive businesses.\n\n'
            '10%–15% — Healthy. Many established companies operate in '
            'this range.\n\n'
            '15%–20% — Very strong. Often indicates a high-quality '
            'business.\n\n'
            'Above 20% — Excellent. Companies that consistently maintain '
            'ROE above 20% often have durable competitive advantages.\n\n'
            'Above 30% — Exceptional, but requires closer examination. '
            'Sometimes a very high ROE reflects an outstanding business. '
            'Other times, it may simply result from very high debt.',
      ),
      MetricInfoSection(
        header: 'Why can a high ROE be misleading?',
        body:
            'A company can increase ROE in two very different ways.\n\n'
            'Good reason — It becomes more profitable.\n\n'
            'Risky reason — It borrows large amounts of money.\n\n'
            'When debt increases, Shareholders\' Equity becomes smaller '
            'relative to total assets. A smaller equity base can make ROE '
            'appear much higher — even if the business itself has not '
            'improved.\n\n'
            'For this reason, ROE should always be analyzed together with '
            'Debt Levels.',
      ),
      MetricInfoSection(
        header: 'Can a low ROE still be acceptable?',
        body:
            'Yes. Young companies often invest heavily in: new factories, '
            'research, expansion, or new products. These investments '
            'increase Shareholders\' Equity before they begin generating '
            'significant profits.\n\n'
            'As a result, ROE may remain low for several years while the '
            'business is still growing.',
      ),
      MetricInfoSection(
        header: 'Can ROE be negative?',
        body:
            'Yes. A negative ROE means the company reported a net loss. '
            'However, this does not automatically mean the company is '
            'failing.\n\n'
            'Possible reasons include: temporary recession, major '
            'investments, one-time accounting losses, acquisitions, '
            'restructuring, or extraordinary expenses.\n\n'
            'The important question is whether profitability is expected '
            'to recover.',
      ),
      MetricInfoSection(
        header: 'Why do investors like stable ROE?',
        body:
            'One excellent year means very little. A company that '
            'consistently generates ROE around 18–21% over many years '
            'demonstrates stable management and a durable business '
            'model.\n\n'
            'Consistency is often more valuable than occasional spikes.',
      ),
      MetricInfoSection(
        header: 'Common mistakes beginners make',
        body:
            '• Looking only at one year\'s ROE.\n'
            '• Ignoring debt.\n'
            '• Comparing unrelated industries.\n'
            '• Assuming every high ROE is a sign of quality.\n'
            '• Ignoring long-term trends.',
      ),
      MetricInfoSection(
        header: 'Best used together with',
        body:
            'ROE becomes much more powerful when combined with: Debt to '
            'Equity, Net Margin, Operating Margin, Gross Margin, Free Cash '
            'Flow, Revenue Growth, and P/E Ratio.\n\n'
            'These metrics help determine whether high profitability is '
            'sustainable.',
      ),
      MetricInfoSection(
        header: 'Real-world analogy',
        body:
            'Imagine two business owners. Both invested \$100,000 into '
            'their companies.\n\n'
            'Owner A earns \$8,000 per year. ROE = 8%\n\n'
            'Owner B earns \$25,000. ROE = 25%\n\n'
            'Owner B is using the same amount of invested capital much '
            'more efficiently. That is exactly what ROE measures.',
      ),
      MetricInfoSection(
        header: 'Why long-term investors watch ROE closely',
        body:
            'Many successful long-term investors favor companies that '
            'consistently generate high ROE over many years.\n\n'
            'Why? Because consistently high ROE may indicate: strong '
            'management, durable competitive advantages, efficient use of '
            'capital, and a business capable of generating long-term '
            'value for shareholders.\n\n'
            'That said, high ROE should always be checked against '
            'reasonable debt levels — see below.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'ROE measures how efficiently a company turns shareholders\' '
            'money into profit. A consistently high ROE often signals a '
            'high-quality business, but investors should always check '
            'whether that performance is driven by genuine profitability '
            'or excessive debt.',
      ),
    ],
  ),
  'valuation': MetricInfoContent(
    title: 'Valuation',
    subtitle: 'How Fairly the Market Is Pricing the Company',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What is Valuation?',
        body:
            'Valuation measures how fairly the market is pricing a company '
            'based on its financial performance and compared to other '
            'companies in the same industry.\n\n'
            'In simple terms: it helps you understand whether investors may '
            'be paying too much—or too little—for the company\'s '
            'stock.\n\n'
            'However, an expensive stock is not always a bad investment, '
            'and a cheap stock is not always a good one.',
      ),
      MetricInfoSection(
        header: 'Why is Valuation important?',
        body:
            'When investors buy a stock, they are buying more than the '
            'company\'s current business—they are also buying expectations '
            'for its future.\n\n'
            'Sometimes expectations become overly optimistic, causing the '
            'stock price to rise much faster than the company\'s actual '
            'performance.\n\n'
            'At other times, the market becomes overly pessimistic, '
            'allowing high-quality companies to trade below what many '
            'investors believe is their fair value.\n\n'
            'Valuation helps investors judge whether the current price '
            'appears reasonable.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Valuation score suggests that the company\'s current '
            'market price appears reasonable relative to its financial '
            'performance and compared with similar companies.\n\n'
            'It does not guarantee that the stock will rise, but it '
            'generally indicates a lower risk of overpaying.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Valuation score may indicate that investors are paying '
            'a premium for the company\'s shares.\n\n'
            'This increases the risk that future expectations are already '
            'reflected in the stock price.\n\n'
            'If the company fails to meet those expectations, the stock '
            'may decline—even if the business itself remains healthy.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Some companies trade at premium valuations for many years '
            'because they have:\n\n'
            '• Strong competitive advantages\n'
            '• Rapid earnings growth\n'
            '• Market leadership\n'
            '• Innovative products\n'
            '• High investor confidence\n\n'
            'In these cases, a higher valuation may be fully justified.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'Even if a company appears attractively valued, there is no '
            'guarantee that its stock price will increase.\n\n'
            'Sometimes the market is already aware of risks that are not '
            'yet fully reflected in financial reports.\n\n'
            'That is why Valuation should always be considered alongside '
            'financial strength, profitability, and future growth '
            'potential.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Valuation helps estimate the risk of overpaying, but it does '
            'not measure the overall quality of a business.\n\n'
            'A company should always be evaluated using multiple financial '
            'indicators rather than relying on valuation alone.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Valuation helps determine whether a company\'s current market '
            'price appears fair relative to its financial performance. It '
            'is a valuable tool for identifying the risk of overpaying, '
            'but it should never be used as the only factor when '
            'evaluating an investment.',
      ),
    ],
  ),
  'financial-health': MetricInfoContent(
    title: 'Financial Health',
    subtitle: 'Stability and Ability to Manage Debt',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What is Financial Health?',
        body:
            'Financial Health evaluates a company\'s overall financial '
            'stability and its ability to manage debt and long-term '
            'obligations.\n\n'
            'In simple terms: it helps determine whether a company has a '
            'strong financial foundation or may face increased financial '
            'risk in the future.\n\n'
            'A financially healthy company is generally better prepared to '
            'navigate economic downturns, invest in future growth, and '
            'adapt to changing market conditions.',
      ),
      MetricInfoSection(
        header: 'Why is Financial Health important?',
        body:
            'Every business needs money to operate and grow.\n\n'
            'Some companies rely mostly on their own resources, while '
            'others depend heavily on borrowed money.\n\n'
            'Debt is not necessarily bad—it can help a business expand, '
            'build new facilities, or acquire competitors. However, '
            'excessive debt can become a serious burden, especially during '
            'periods of slower growth or higher interest rates.\n\n'
            'Financial Health helps investors understand how resilient a '
            'company may be under different economic conditions.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Financial Health score suggests that the company '
            'appears financially stable and is managing its obligations '
            'responsibly.\n\n'
            'Companies with strong financial health are generally in a '
            'better position to:\n\n'
            '• Invest in future growth\n'
            '• Handle unexpected challenges\n'
            '• Continue operations during economic downturns\n'
            '• Maintain financial flexibility\n\n'
            'While no company is completely risk-free, a stronger '
            'financial position often provides greater long-term '
            'stability.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Financial Health score may indicate that the company is '
            'carrying a higher level of financial risk.\n\n'
            'This could reduce its flexibility and make it more vulnerable '
            'during difficult economic periods.\n\n'
            'Companies with weaker financial health may face challenges '
            'such as:\n\n'
            '• Higher borrowing costs\n'
            '• Reduced ability to invest\n'
            '• Greater pressure during recessions\n'
            '• Increased sensitivity to rising interest rates\n\n'
            'A lower score does not necessarily mean the company is in '
            'trouble, but it deserves closer attention.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Some industries naturally rely on higher levels of debt.\n\n'
            'For example:\n\n'
            '• Utilities\n'
            '• Telecommunications\n'
            '• Real estate\n'
            '• Infrastructure companies\n\n'
            'These businesses often generate stable cash flows that allow '
            'them to manage larger debt levels safely.\n\n'
            'As a result, financial health should always be considered '
            'within the context of the company\'s industry and business '
            'model.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'Even financially strong companies can face unexpected '
            'challenges.\n\n'
            'Market disruptions, changing consumer demand, poor management '
            'decisions, or global economic events can affect any '
            'business.\n\n'
            'Financial Health reduces risk—it does not eliminate it.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Financial Health reflects a company\'s ability to remain '
            'stable over time, but it is only one part of the overall '
            'picture.\n\n'
            'A company should also be evaluated based on its '
            'profitability, valuation, growth potential, and operational '
            'efficiency.\n\n'
            'Looking at all these factors together provides a much more '
            'balanced assessment.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Financial Health measures the overall financial strength and '
            'stability of a company. Businesses with stronger financial '
            'foundations are generally better equipped to manage '
            'uncertainty, support future growth, and withstand economic '
            'challenges, but no single indicator should be used in '
            'isolation.',
      ),
    ],
  ),
  'growth-potential': MetricInfoContent(
    title: 'Growth Potential',
    subtitle: 'How Consistently the Business Has Expanded',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What is Growth Potential?',
        body:
            'Growth Potential evaluates how consistently a company has '
            'expanded its business over time by increasing its revenue '
            'and earnings.\n\n'
            'In simple terms: it helps determine whether a company is '
            'growing, standing still, or gradually losing momentum.\n\n'
            'Growing companies often have more opportunities to increase '
            'their value over the long term, although growth is never '
            'guaranteed.',
      ),
      MetricInfoSection(
        header: 'Why is Growth Potential important?',
        body:
            'A successful company should not only be profitable '
            'today—it should also have the ability to grow in the '
            'future.\n\n'
            'Business growth may come from:\n\n'
            '• Selling more products\n'
            '• Expanding into new markets\n'
            '• Launching new services\n'
            '• Increasing market share\n'
            '• Improving operational performance\n\n'
            'Consistent growth often reflects strong demand, effective '
            'management, and a healthy business strategy.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Growth Potential score suggests that the company has '
            'demonstrated strong and consistent business growth over '
            'time.\n\n'
            'Companies with higher growth potential are often better '
            'positioned to:\n\n'
            '• Increase future earnings\n'
            '• Expand their operations\n'
            '• Strengthen their competitive position\n'
            '• Create long-term value for shareholders\n\n'
            'Consistent growth is generally viewed as a positive sign of '
            'business quality.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Growth Potential score may indicate that business '
            'expansion has slowed or become inconsistent.\n\n'
            'Possible reasons include:\n\n'
            '• Slower customer demand\n'
            '• Increased competition\n'
            '• Market saturation\n'
            '• Economic challenges\n'
            '• Company-specific issues\n\n'
            'A lower score does not necessarily mean the business is weak, '
            'but it may suggest fewer growth opportunities in the near '
            'future.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Not every successful company needs to grow rapidly.\n\n'
            'Many mature businesses focus on:\n\n'
            '• Stable earnings\n'
            '• Reliable dividends\n'
            '• Strong cash flow\n'
            '• Long-term consistency\n\n'
            'These companies may deliver attractive long-term returns even '
            'without rapid expansion.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'Rapid growth often comes with higher expectations.\n\n'
            'If future growth slows, investors may react negatively, even '
            'if the company continues to perform well.\n\n'
            'Growth can also become more difficult as companies become '
            'larger and more established.\n\n'
            'For this reason, sustainable growth is generally more '
            'valuable than short periods of exceptional performance.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Growth should always be evaluated together with profitability '
            'and financial stability.\n\n'
            'A company that grows rapidly while consistently generating '
            'healthy profits is often in a stronger position than one that '
            'grows quickly but struggles financially.\n\n'
            'Long-term consistency is usually more important than '
            'short-term acceleration.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Growth Potential measures how consistently a company has '
            'expanded its business over time. Strong and sustainable '
            'growth can create long-term opportunities, but it should '
            'always be considered alongside profitability, financial '
            'health, and overall business quality.',
      ),
    ],
  ),
  // Marker label is "Efficiency" (financial_score_widget.dart), computed in
  // scoring_engine.dart from net margin + ROE — i.e. profitability, not
  // day-to-day operational/resource management. Content below matches what
  // the marker actually measures rather than its short label.
  'efficiency': MetricInfoContent(
    title: 'Efficiency',
    subtitle: 'How Effectively Revenue Becomes Profit',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What is Profitability?',
        body:
            'Profitability measures how effectively a company turns its '
            'revenue into profit.\n\n'
            'In simple terms: it helps determine whether a company is '
            'making money efficiently—or simply generating a lot of sales '
            'with little profit.\n\n'
            'A profitable company is generally better positioned to invest '
            'in growth, reward shareholders, and navigate challenging '
            'economic conditions.',
      ),
      MetricInfoSection(
        header: 'Why is Profitability important?',
        body:
            'Revenue alone does not tell the full story.\n\n'
            'A company may generate billions of dollars in sales but keep '
            'only a small portion as profit.\n\n'
            'Another company may generate lower revenue but operate much '
            'more efficiently, producing stronger and more consistent '
            'earnings.\n\n'
            'Profitability helps investors understand the quality of a '
            'company\'s business model.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Profitability score suggests that the company '
            'consistently converts a meaningful portion of its revenue '
            'into profit.\n\n'
            'Companies with strong profitability are often better '
            'positioned to:\n\n'
            '• Invest in future growth\n'
            '• Expand their operations\n'
            '• Pay dividends\n'
            '• Repurchase shares\n'
            '• Build financial reserves\n'
            '• Withstand economic downturns\n\n'
            'Consistently profitable businesses often demonstrate '
            'efficient management and strong competitive advantages.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Profitability score may indicate that the company is '
            'struggling to generate healthy profits.\n\n'
            'Possible reasons include:\n\n'
            '• Rising operating costs\n'
            '• Intense competition\n'
            '• Weak pricing power\n'
            '• Declining demand\n'
            '• Poor cost management\n'
            '• Temporary business challenges\n\n'
            'Lower profitability may reduce a company\'s ability to grow '
            'or respond to unexpected financial pressures.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Some businesses naturally operate with lower profit '
            'margins.\n\n'
            'Examples include:\n\n'
            '• Supermarkets\n'
            '• Airlines\n'
            '• Wholesale distributors\n'
            '• Large retail chains\n\n'
            'These industries often rely on very high sales volumes rather '
            'than large profits on each sale.\n\n'
            'A lower profitability score should always be evaluated within '
            'the context of the company\'s industry.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'Strong profitability today does not guarantee strong '
            'profitability tomorrow.\n\n'
            'Changing market conditions, increased competition, higher '
            'costs, or economic slowdowns can all reduce future '
            'earnings.\n\n'
            'Investors should look for companies that have demonstrated '
            'consistent profitability over many years, rather than relying '
            'on a single strong reporting period.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Profitability is one of the strongest indicators of business '
            'quality, but it should never be viewed in isolation.\n\n'
            'A complete evaluation should also consider:\n\n'
            '• Financial Health\n'
            '• Growth Potential\n'
            '• Valuation\n'
            '• Operational Efficiency\n\n'
            'Looking at these factors together provides a much clearer '
            'understanding of a company\'s long-term prospects.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Profitability measures how efficiently a company converts '
            'revenue into profit. Businesses with strong and consistent '
            'profitability are often better equipped to grow, invest, and '
            'withstand economic challenges, but profitability should '
            'always be evaluated alongside other aspects of financial '
            'performance.',
      ),
    ],
  ),
  // Marker label is "Historical Trend" (financial_score_widget.dart),
  // computed in scoring_engine.dart from real 5Y share-price CAGR — a
  // market-driven signal (not a fundamental), so "Market Confidence"
  // content maps here rather than to Capital Return (dividends/buybacks).
  'historical-trend': MetricInfoContent(
    title: 'Historical Trend',
    subtitle: 'How the Market Has Rewarded the Company Over Time',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What is Market Confidence?',
        body:
            'Market Confidence reflects how investors currently perceive a '
            'company based on its overall performance, stability, and '
            'future prospects.\n\n'
            'In simple terms: it helps determine whether the market has '
            'confidence in the company\'s future or is becoming more '
            'cautious.\n\n'
            'Investor confidence can strongly influence a stock\'s price, '
            'especially over the short and medium term.',
      ),
      MetricInfoSection(
        header: 'Why is Market Confidence important?',
        body:
            'The stock market is driven by both facts and expectations.\n\n'
            'A company may report excellent financial results, but if '
            'investors expect even better performance, the stock price can '
            'still fall.\n\n'
            'Likewise, a company with average results may see its stock '
            'rise if investors believe its future is improving.\n\n'
            'Market Confidence helps investors understand how the market '
            'is currently viewing the business.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Market Confidence score suggests that investors '
            'generally have a positive view of the company\'s future.\n\n'
            'Companies with strong market confidence often benefit '
            'from:\n\n'
            '• Positive investor sentiment\n'
            '• Stable long-term expectations\n'
            '• Strong reputation\n'
            '• Confidence in management\n'
            '• Optimism about future growth\n\n'
            'Higher confidence can make it easier for a company to raise '
            'capital and attract long-term investors.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Market Confidence score may indicate that investors are '
            'becoming more cautious.\n\n'
            'Possible reasons include:\n\n'
            '• Slowing business growth\n'
            '• Weak financial results\n'
            '• Increased competition\n'
            '• Industry uncertainty\n'
            '• Economic concerns\n'
            '• Company-specific challenges\n\n'
            'Lower confidence does not necessarily mean the company is '
            'performing poorly, but it often signals increased '
            'uncertainty.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Investor sentiment can change quickly.\n\n'
            'Sometimes the market reacts emotionally to short-term news, '
            'temporary setbacks, or broader economic conditions.\n\n'
            'Strong companies occasionally experience periods of lower '
            'confidence before recovering as business conditions '
            'improve.\n\n'
            'For long-term investors, temporary pessimism may even create '
            'attractive opportunities.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'High investor confidence can sometimes become excessive.\n\n'
            'When expectations become unrealistically optimistic, stock '
            'prices may rise much faster than the underlying business.\n\n'
            'If future results fail to meet those expectations, investor '
            'confidence can decline rapidly, leading to increased price '
            'volatility.\n\n'
            'Confidence should always be supported by strong business '
            'fundamentals.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Market Confidence reflects how investors currently feel about '
            'a company, but market sentiment can change much faster than '
            'the business itself.\n\n'
            'For a balanced investment decision, Market Confidence should '
            'always be considered together with:\n\n'
            '• Valuation\n'
            '• Financial Health\n'
            '• Growth Potential\n'
            '• Profitability\n'
            '• Operational Efficiency\n\n'
            'Strong companies are built on solid fundamentals—not on '
            'market optimism alone.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Market Confidence reflects how investors currently view a '
            'company\'s future. Positive sentiment can support stock '
            'performance, while declining confidence may increase '
            'uncertainty. However, investor sentiment should always be '
            'evaluated alongside the company\'s underlying financial '
            'strength and long-term business quality.',
      ),
    ],
  ),
  'capital-return': MetricInfoContent(
    title: 'Shareholder Returns',
    subtitle: 'Dividends and Share Buybacks',
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What are Shareholder Returns?',
        body:
            'Shareholder Returns evaluate how a company rewards its '
            'shareholders by returning value through dividends and share '
            'buybacks.\n\n'
            'In simple terms: it helps determine how effectively a '
            'company shares its financial success with investors.\n\n'
            'Some companies reward shareholders by paying regular '
            'dividends, while others choose to repurchase their own '
            'shares. Many successful businesses use both approaches.',
      ),
      MetricInfoSection(
        header: 'Why are Shareholder Returns important?',
        body:
            'When a company generates profits, management must decide how '
            'to use that money.\n\n'
            'Common options include:\n\n'
            '• Investing in future growth\n'
            '• Reducing debt\n'
            '• Building cash reserves\n'
            '• Paying dividends\n'
            '• Repurchasing company shares\n\n'
            'Returning capital to shareholders can demonstrate financial '
            'strength and confidence in the company\'s future.',
      ),
      MetricInfoSection(
        header: 'What does a high score mean?',
        body:
            'A high Shareholder Returns score suggests that the company '
            'has a consistent and shareholder-friendly approach to '
            'returning value.\n\n'
            'This may include:\n\n'
            '• Reliable dividend payments\n'
            '• Sustainable dividend growth\n'
            '• Thoughtful share repurchase programs\n'
            '• A balanced capital allocation strategy\n\n'
            'Companies with strong shareholder return policies often focus '
            'on creating long-term value rather than short-term results.',
      ),
      MetricInfoSection(
        header: 'What does a low score mean?',
        body:
            'A low Shareholder Returns score does not necessarily indicate '
            'poor business quality.\n\n'
            'Possible reasons include:\n\n'
            '• Reinvesting profits into future growth\n'
            '• Expanding operations\n'
            '• Developing new products\n'
            '• Acquiring other businesses\n'
            '• Strengthening the balance sheet\n\n'
            'Many successful companies choose to reinvest their earnings '
            'instead of returning cash directly to shareholders.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a low score always bad?',
        body:
            'Fast-growing companies often generate better long-term '
            'returns by investing in their own business rather than '
            'paying dividends or buying back shares.\n\n'
            'If those investments produce higher future earnings, '
            'shareholders may benefit through long-term stock price '
            'appreciation instead of immediate cash distributions.\n\n'
            'Growth-focused companies frequently follow this strategy '
            'during their expansion years.',
      ),
      MetricInfoSection(
        header: 'Why isn\'t a high score always a guarantee?',
        body:
            'Returning cash to shareholders is generally positive—but '
            'only when it is financially sustainable.\n\n'
            'For example:\n\n'
            '• A company may pay an unusually high dividend that cannot '
            'be maintained.\n'
            '• A business may repurchase shares while taking on excessive '
            'debt.\n\n'
            'Capital returned to shareholders should never weaken the '
            'company\'s long-term financial stability.\n\n'
            'Healthy shareholder returns should be supported by strong '
            'earnings, cash flow, and a solid financial position.',
      ),
      MetricInfoSection(
        header: 'What should investors pay attention to?',
        body:
            'Shareholder Returns should be viewed as part of the '
            'company\'s overall capital allocation strategy.\n\n'
            'A company that balances:\n\n'
            '• Business investment\n'
            '• Financial stability\n'
            '• Sustainable dividends\n'
            '• Responsible share buybacks\n\n'
            'is often creating greater long-term value for its '
            'shareholders.\n\n'
            'There is no single "best" approach. The right strategy '
            'depends on the company\'s stage of growth, industry, and '
            'long-term objectives.',
      ),
      MetricInfoSection(
        header: 'Key Takeaway',
        body:
            'Shareholder Returns measure how a company rewards investors '
            'through dividends and share buybacks. Strong shareholder '
            'returns often reflect disciplined financial management, but '
            'they should always be supported by healthy earnings, '
            'sustainable cash flow, and a solid financial foundation.',
      ),
    ],
  ),
  // Reached by tapping the gold "Legal Disclaimer & Methodology" link at
  // the bottom of FinancialScoreWidget — full legal-grade text, the
  // compact on-card line is a summary of this.
  'fs-score-legal': MetricInfoContent(
    title: 'Legal Disclaimer',
    subtitle: 'Financial Scoring & Market Data',
    sections: [
      MetricInfoSection(
        body:
            'The financial evaluation metrics (including FS Score) '
            'displayed in this application are calculated automatically '
            'using mathematical algorithms applied to publicly accessible '
            'market data and corporate financial disclosures (such as '
            '10-K, 10-Q SEC filings).\n\n'
            'These scores are strictly analytical outputs intended for '
            'educational and market research simulation. They do not '
            'constitute investment advice, financial recommendations, '
            'credit ratings, or endorsements of any security or '
            'entity.\n\n'
            'Neither the app nor its developers warrant the accuracy, '
            'completeness, or timeliness of the underlying data or '
            'calculated metrics. Users assume full responsibility for any '
            'trading or investment decisions made independently outside '
            'of this educational simulator.',
      ),
    ],
  ),
  // Reached by tapping the "?" in the Portfolio Balance detail screen's
  // 4 widget headers (stress_test_portfolio_balance_screen.dart and its
  // widgets/ files) — not part of company_detail's KEY METRICS/FS Score
  // rows, just reusing the same MetricInfoScreen shape.
  'portfolio-health': MetricInfoContent(
    title: 'Portfolio Health',
    subtitle: 'Overall Portfolio Quality Assessment',
    sections: [
      MetricInfoSection(
        body:
            'Portfolio Health provides an overall assessment of your '
            'portfolio\'s structure and investment quality. Instead of '
            'reviewing many separate statistics, this widget combines '
            'several important indicators into a single summary that '
            'helps you understand whether your portfolio follows healthy '
            'investing principles.\n\n'
            'A strong portfolio is not determined only by profit or loss. '
            'Even a portfolio that is currently making money can contain '
            'hidden weaknesses, such as too much money invested in one '
            'company or too many investments concentrated in a single '
            'industry. These risks may not be obvious during a rising '
            'market, but they can become much more noticeable when market '
            'conditions change.\n\n'
            'The Portfolio Health widget analyzes different aspects of '
            'your portfolio, including diversification, concentration, '
            'sector balance, and overall stability. Each indicator '
            'contributes to the final picture and helps identify areas '
            'that may need improvement.\n\n'
            'A higher score generally means your investments are spread '
            'more effectively, reducing unnecessary risk and making your '
            'portfolio more resilient to unexpected market events. A '
            'lower score does not necessarily mean your portfolio is bad, '
            'but it may suggest that some adjustments could improve its '
            'balance and reduce exposure to avoidable risks.\n\n'
            'This widget is designed to help investors focus on building '
            'a healthier portfolio over time rather than reacting to '
            'short-term market movements.',
      ),
    ],
  ),
  'asset-allocation-pct': MetricInfoContent(
    title: 'Asset Allocation %',
    subtitle: 'How Your Capital Is Distributed',
    sections: [
      MetricInfoSection(
        body:
            'Asset Allocation shows exactly how your investment capital '
            'is distributed among the individual companies you own.\n\n'
            'Every percentage displayed represents the portion of your '
            'total portfolio invested in a specific company. As stock '
            'prices change over time, these percentages also change '
            'automatically. A company that performs very well may '
            'gradually become a much larger part of your portfolio, even '
            'if you never purchase additional shares.\n\n'
            'Monitoring asset allocation is important because excessive '
            'concentration can increase risk. If one company represents '
            'a large percentage of your investments, the success or '
            'failure of that single business will have a much greater '
            'influence on your overall portfolio.\n\n'
            'A balanced allocation helps reduce dependence on any '
            'individual company. While there is no perfect distribution '
            'that fits every investor, avoiding extremely large positions '
            'can help create a more stable investment portfolio over the '
            'long term.\n\n'
            'This widget allows you to quickly identify your largest '
            'holdings, monitor how your portfolio evolves, and decide '
            'whether your allocation still matches your investment '
            'goals.',
      ),
    ],
  ),
  'diversification-indicator': MetricInfoContent(
    title: 'Diversification Indicator',
    subtitle: 'Sector Balance Across Your Holdings',
    sections: [
      MetricInfoSection(
        body:
            'Diversification Indicator measures how your investments are '
            'distributed across different sectors of the economy.\n\n'
            'Every company belongs to a particular industry or business '
            'sector, such as Technology, Healthcare, Financial Services, '
            'Consumer Goods, Energy, Industrials, Utilities, or Real '
            'Estate. Different sectors often perform differently '
            'depending on economic conditions, interest rates, consumer '
            'demand, or global events.\n\n'
            'If most of your money is invested in only one sector, your '
            'portfolio becomes more vulnerable to problems affecting that '
            'industry. For example, a decline in technology companies may '
            'have a significant impact if your portfolio consists mainly '
            'of technology stocks.\n\n'
            'A portfolio spread across multiple sectors can reduce this '
            'type of risk because different industries may perform '
            'differently during the same period. While one sector '
            'struggles, another may remain stable or continue growing.\n\n'
            'This widget helps you understand which sectors make up your '
            'portfolio, identify areas that may be overrepresented, and '
            'discover sectors that are currently missing. Building sector '
            'diversification gradually can improve the overall balance of '
            'your investments without requiring you to own a very large '
            'number of companies.',
      ),
    ],
  ),
  'diversification-progress': MetricInfoContent(
    title: 'Diversification Progress',
    subtitle: 'Building a Broader Portfolio Over Time',
    sections: [
      MetricInfoSection(
        body:
            'Diversification Progress tracks how your portfolio grows by '
            'measuring the number of different companies you own.\n\n'
            'For many long-term investors, diversification is built '
            'gradually over months or even years. Every new investment '
            'has the potential to increase the variety of businesses '
            'represented in the portfolio and reduce dependence on any '
            'single company.\n\n'
            'Owning only a few companies means that each investment has a '
            'greater influence on your portfolio\'s performance. As the '
            'number of holdings increases, the impact of one company\'s '
            'poor performance usually becomes smaller, creating a more '
            'balanced investment structure.\n\n'
            'However, diversification is not simply about buying as many '
            'companies as possible. A portfolio with many businesses from '
            'the same industry may still be poorly diversified. True '
            'diversification combines both the number of companies and '
            'the variety of sectors they represent.\n\n'
            'This widget allows you to monitor your progress toward '
            'building a broader portfolio. Watching this number grow over '
            'time can encourage disciplined investing and remind you '
            'that diversification is a gradual process rather than '
            'something achieved in a single day.\n\n'
            'As your portfolio expands, this widget provides a simple '
            'visual indication of how far you have progressed on your '
            'long-term diversification journey.',
      ),
    ],
  ),

  // ── Psychology Meter marker widgets (stress_test/widgets/psychology/) ──
  // Stub copy — placeholder text pending final wording from the user.
  'psychology-discipline': MetricInfoContent(
    title: 'Discipline',
    subtitle: 'Buying With a Plan, Not With Emotion',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Is Investment Discipline?',
        body:
            'Investment discipline is the ability to make decisions '
            'based on a strategy rather than emotions.\n\n'
            'The market constantly creates situations that test '
            'investors:\n\n'
            'When prices rise quickly — excitement appears and the '
            'fear of missing out begins.\n\n'
            'When markets fall — fear appears and investors often '
            'hesitate or panic.\n\n'
            'Many investment mistakes do not happen because people '
            'lack investing knowledge.\n\n'
            'They happen because emotions push investors to change '
            'their decisions at the worst possible moments.\n\n'
            'Discipline helps investors stay committed to their '
            'strategy regardless of what is happening around them.',
      ),
      MetricInfoSection(
        header: 'A Simple Example',
        body:
            'Imagine two investors.\n\n'
            'They both have the same amount of money and access to '
            'the same information.',
      ),
      MetricInfoSection(
        header: 'Investor A',
        body:
            'The market is rising quickly.\n\n'
            'The news is full of stories about one popular company.\n\n'
            'Everyone is talking about its future potential.\n\n'
            'The investor buys because they are afraid of missing the '
            'opportunity.\n\n'
            'A few months later, the market changes.\n\n'
            'The stock price falls.\n\n'
            'The investor sells because fear takes over.\n\n'
            'Their decisions are controlled by emotions.',
      ),
      MetricInfoSection(
        header: 'Investor B',
        body:
            'Before buying, they ask important questions:\n\n'
            'Why am I buying this company?\n'
            'Has the real value of the business changed?\n'
            'Does this purchase fit my investment strategy?\n\n'
            'When the market rises, they don\'t buy simply because '
            'everyone is excited.\n\n'
            'When the market falls, they look for opportunities.\n\n'
            'Their decisions are based on a process, not market '
            'emotions.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Track?',
        body:
            'This widget analyzes your buying history and evaluates '
            'how closely your actions follow the principles of '
            'disciplined investing.\n\n'
            'It does not only look at the outcome of your '
            'investments.\n\n'
            'It looks at the conditions and environment in which your '
            'decisions were made.',
      ),
      MetricInfoSection(
        header: 'Buying During Market Fear',
        body:
            'Buying during:\n\n'
            'market declines;\n'
            'financial crises;\n'
            'periods of extreme uncertainty;\n\n'
            'can demonstrate the ability to act when many investors '
            'are afraid.',
      ),
      MetricInfoSection(
        header: 'Buying During Market Excitement',
        body:
            'Buying during:\n\n'
            'market hype;\n'
            'rapid price increases;\n'
            'massive attention around a specific theme;\n\n'
            'can indicate an emotional decision and the desire to '
            'avoid missing out.',
      ),
      MetricInfoSection(
        header: 'Risk Control During Opportunities',
        body:
            'Even a good investment idea requires good execution.\n\n'
            'A strong investor does not only recognize '
            'opportunities.\n\n'
            'They also manage position sizes and maintain '
            'flexibility.\n\n'
            'For example, buying during a market decline while '
            'keeping a cash reserve shows a more controlled and '
            'thoughtful approach.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Teach?',
        body:
            'This widget teaches one of the most important skills of '
            'a long-term investor:\n\n'
            'Managing not only your portfolio, but also your own '
            'behavior.\n\n'
            'Because the market cannot be controlled.\n\n'
            'You cannot control:\n\n'
            'news;\n'
            'the economy;\n'
            'price movements;\n'
            'the emotions of other investors.\n\n'
            'But you can control:\n\n'
            'your decisions;\n'
            'your strategy;\n'
            'your reaction to events.',
      ),
      MetricInfoSection(
        header: 'The Main Idea',
        body:
            'A successful investor is not someone who never makes '
            'mistakes.\n\n'
            'Everyone makes mistakes.\n\n'
            'A successful investor is someone who can continue making '
            'rational decisions even when the market creates maximum '
            'pressure.\n\n'
            'Your strategy shows what you buy.\n\n'
            'Your discipline shows why you buy it.',
      ),
    ],
  ),
  'psychology-panic': MetricInfoContent(
    title: 'Panic',
    subtitle: 'Selling Calmly, Not Selling Scared',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Is Panic in Investing?',
        body:
            'Panic in investing is not simply feeling fear.\n\n'
            'Fear is a natural reaction when money is involved.\n\n'
            'Every investor experiences uncertainty when prices '
            'fall.\n\n'
            'The problem begins when fear starts controlling '
            'decisions.\n\n'
            'A falling stock price does not automatically mean a bad '
            'investment.\n\n'
            'Sometimes a declining price means:\n\n'
            'the entire market is under pressure;\n'
            'investors are temporarily afraid;\n'
            'a good company is becoming cheaper.\n\n'
            'But during stressful periods, many investors make '
            'decisions based on emotions instead of analysis.\n\n'
            'They sell because the situation feels uncomfortable.\n\n'
            'They sell because they want to stop the pain.\n\n'
            'They sell because they believe the decline will continue '
            'forever.\n\n'
            'This is one of the most common mistakes in investing.',
      ),
      MetricInfoSection(
        header: 'A Simple Example',
        body:
            'Imagine an investor buys shares of a strong company.\n\n'
            'The business is growing.\n\n'
            'The financial results are healthy.\n\n'
            'The long-term idea remains unchanged.\n\n'
            'But then the market enters a difficult period.\n\n'
            'The stock price falls:\n\n'
            '-20%.\n\n'
            'Then:\n\n'
            '-35%.\n\n'
            'Negative headlines appear everywhere.\n\n'
            'Many investors become afraid.',
      ),
      MetricInfoSection(
        header: 'Investor A',
        body:
            'The falling price creates stress.\n\n'
            'They think:\n\n'
            '"I cannot handle this loss anymore."\n\n'
            'They sell near the worst moment.\n\n'
            'A few months later, the market begins recovering.\n\n'
            'The problem was not only the price decline.\n\n'
            'The problem was making a decision at the moment when '
            'emotions were strongest.',
      ),
      MetricInfoSection(
        header: 'Investor B',
        body:
            'They review the original investment idea.\n\n'
            'They ask:\n\n'
            'Did the company become weaker?\n'
            'Did the business model change?\n'
            'Is this a temporary market reaction?\n\n'
            'If the investment reason is still valid, they remain '
            'patient.\n\n'
            'They understand that volatility is part of investing.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Track?',
        body:
            'This widget analyzes your selling behavior and evaluates '
            'how you react during difficult market situations.\n\n'
            'It does not judge every losing sale as a mistake.\n\n'
            'Selling at a loss can sometimes be the correct '
            'decision.\n\n'
            'A smart investor may sell because:\n\n'
            'the business fundamentals changed;\n'
            'the original investment idea is no longer valid;\n'
            'a better opportunity appeared.\n\n'
            'The important question is:\n\n'
            'Why did you sell?',
      ),
      MetricInfoSection(
        header: 'Selling During Fear',
        body:
            'The system looks at whether sales happened during '
            'periods of extreme market pressure.\n\n'
            'Selling close to major declines can indicate an '
            'emotional reaction, especially if the investment later '
            'recovers.',
      ),
      MetricInfoSection(
        header: 'Ability to Accept Volatility',
        body:
            'Successful investors understand that price movement is '
            'normal.\n\n'
            'Strong companies can experience temporary declines.\n\n'
            'This widget helps measure whether you can separate '
            'temporary market noise from real problems with an '
            'investment.',
      ),
      MetricInfoSection(
        header: 'Surviving Extreme Market Events',
        body:
            'The strongest test of an investor often comes during '
            'crises.\n\n'
            'Market crashes create:\n\n'
            'uncertainty;\n'
            'fear;\n'
            'pressure to act.\n\n'
            'Investors who can survive these periods without '
            'emotional decisions demonstrate one of the most valuable '
            'skills in investing:\n\n'
            'patience.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Teach?',
        body:
            'This widget teaches that investing is not only about '
            'choosing the right assets.\n\n'
            'It is also about controlling your reactions when things '
            'do not go according to plan.\n\n'
            'You cannot control:\n\n'
            'market crashes;\n'
            'negative news;\n'
            'temporary price declines.\n\n'
            'But you can control:\n\n'
            'your decisions;\n'
            'your preparation;\n'
            'your response to uncertainty.',
      ),
      MetricInfoSection(
        header: 'The Main Idea',
        body:
            'A great investor is not someone who never experiences '
            'fear.\n\n'
            'Everyone feels fear.\n\n'
            'The difference is what happens next.\n\n'
            'Some investors allow fear to make decisions for them.\n\n'
            'Others use patience, analysis, and a clear strategy.\n\n'
            'Your portfolio shows what you own.\n\n'
            'Your Discipline shows how you buy.\n\n'
            'Your Panic score shows how you behave when the market '
            'tests you.',
      ),
    ],
  ),
  'psychology-patience': MetricInfoContent(
    title: 'Patience',
    subtitle: 'Letting Positions Play Out',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Is Investment Patience?',
        body:
            'Investment patience is the ability to stay focused on a '
            'long-term plan without making unnecessary decisions '
            'because of short-term market movements.\n\n'
            'Many investors believe that successful investing is '
            'about finding the perfect moment to buy or sell.\n\n'
            'But in reality, one of the biggest advantages an '
            'investor has is time.\n\n'
            'The market constantly creates situations that test '
            'patience:\n\n'
            'prices move up and down;\n'
            'unexpected news appears;\n'
            'other investors become excited or afraid;\n'
            'good companies sometimes experience difficult periods.\n\n'
            'During these moments, investors often feel pressure to '
            'act.\n\n'
            'They want to change something.\n\n'
            'They want to fix the situation.\n\n'
            'But sometimes the best decision is not making a decision '
            'at all.',
      ),
      MetricInfoSection(
        header: 'A Simple Example',
        body:
            'Imagine two investors who bought shares of the same '
            'strong company.\n\n'
            'The business continues growing.\n\n'
            'The financial results remain healthy.\n\n'
            'But the market enters a difficult period and the stock '
            'price declines.',
      ),
      MetricInfoSection(
        header: 'Investor A',
        body:
            'The falling price creates stress.\n\n'
            'They think:\n\n'
            '"Maybe I made a mistake. I should do something."\n\n'
            'They sell because the situation feels uncomfortable.\n\n'
            'Later, the company recovers.\n\n'
            'The problem was not the temporary decline.\n\n'
            'The problem was not allowing the original investment '
            'idea enough time.',
      ),
      MetricInfoSection(
        header: 'Investor B',
        body:
            'They review the situation.\n\n'
            'They ask:\n\n'
            'Did the business become weaker?\n'
            'Has the original reason for investing changed?\n'
            'Is this a company problem or only market fear?\n\n'
            'If the investment idea remains valid, they stay '
            'patient.\n\n'
            'They understand that short-term volatility is a normal '
            'part of long-term investing.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Track?',
        body:
            'This widget analyzes your investing behavior and '
            'measures your ability to remain patient during different '
            'market situations.\n\n'
            'It does not simply measure how long you hold an '
            'investment.\n\n'
            'Holding a bad company for many years is not patience.\n\n'
            'True patience means:\n\n'
            'Giving good decisions enough time to work while staying '
            'ready to react when the facts truly change.',
      ),
      MetricInfoSection(
        header: 'Ability to Avoid Unnecessary Actions',
        body:
            'The market creates constant movement.\n\n'
            'Every price change can create an emotional reaction.\n\n'
            'This widget evaluates whether your decisions are based '
            'on:\n\n'
            'new information;\n'
            'changes in business quality;\n'
            'a clear investment reason;\n'
            'or simply on temporary market pressure.',
      ),
      MetricInfoSection(
        header: 'Ability to Stay Calm During Crisis',
        body:
            'The strongest test of patience appears during extreme '
            'events.\n\n'
            'Market crashes create:\n\n'
            'fear;\n'
            'uncertainty;\n'
            'pressure to sell.\n\n'
            'Many investors make their biggest mistakes during these '
            'moments because they focus only on the current '
            'situation.\n\n'
            'A patient investor understands that difficult periods '
            'are part of investing.',
      ),
      MetricInfoSection(
        header: 'Taking Profit Without Greed',
        body:
            'Patience is not only about holding.\n\n'
            'It is also about knowing when enough is enough.\n\n'
            'A disciplined investor can accept a successful result '
            'without waiting forever for a perfect exit.\n\n'
            'Markets rarely provide perfect timing.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Teach?',
        body:
            'This widget teaches one of the most important lessons in '
            'investing:\n\n'
            'Time is one of the greatest advantages an investor can '
            'have.\n\n'
            'You cannot control:\n\n'
            'daily price movements;\n'
            'market emotions;\n'
            'economic events.\n\n'
            'But you can control:\n\n'
            'your reactions;\n'
            'your decision process;\n'
            'your ability to stay focused.',
      ),
      MetricInfoSection(
        header: 'The Main Idea',
        body:
            'Patience does not mean ignoring problems.\n\n'
            'It does not mean holding every investment forever.\n\n'
            'It means understanding the difference between temporary '
            'market noise and real changes that require action.\n\n'
            'The best investors are not those who make the most '
            'decisions.\n\n'
            'They are those who make the right decisions and give '
            'them enough time to work.\n\n'
            'Your Discipline shows how you enter the market.\n\n'
            'Your Panic score shows how you react under pressure.\n\n'
            'Your Patience score shows whether you can let time '
            'become your advantage.',
      ),
    ],
  ),
  'psychology-strategy': MetricInfoContent(
    title: 'Strategy',
    subtitle: 'How Your Portfolio Is Built',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Is an Investment Strategy?',
        body:
            'An investment strategy is not just a list of companies you '
            'own.\n\n'
            'It is a system of rules that guides your decisions.\n\n'
            'A strong strategy answers questions like:\n\n'
            'What am I buying?\n'
            'Why am I buying it?\n'
            'How do I manage risk?\n'
            'What will I do during a market decline?\n'
            'How will I react when new opportunities appear?',
      ),
      MetricInfoSection(
        header: 'A Simple Example',
        body:
            'Two investors can own the same stocks.\n\n'
            'But their strategies can be completely different.',
      ),
      MetricInfoSection(
        header: 'Investor A',
        body:
            'Buys companies because their prices are rising.\n\n'
            'Follows every headline.\n\n'
            'Buys after strong price increases because of fear of '
            'missing out.\n\n'
            'Sells during market declines because of panic.\n\n'
            'They own investments, but they don\'t have a system.',
      ),
      MetricInfoSection(
        header: 'Investor B',
        body:
            'Buys strong businesses.\n\n'
            'Manages position sizes.\n\n'
            'Keeps a cash reserve.\n\n'
            'Uses ETFs for additional diversification.\n\n'
            'Has a plan for different market situations.\n\n'
            'They don\'t simply own stocks.\n\n'
            'They have a strategy.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Track?',
        body:
            'This widget analyzes whether your investing approach '
            'follows the principles of long-term portfolio '
            'management.\n\n'
            'It evaluates:',
      ),
      MetricInfoSection(
        header: 'Quality of Your Investments',
        body:
            'Are you investing in strong businesses with sustainable '
            'models?\n\n'
            'Or are you taking excessive risks hoping for quick '
            'returns?',
      ),
      MetricInfoSection(
        header: 'Balance Between Growth and Protection',
        body:
            'A portfolio should not only perform well during good '
            'markets.\n\n'
            'It should also have the ability to survive difficult '
            'periods.',
      ),
      MetricInfoSection(
        header: 'Preparation for Opportunities',
        body:
            'Investors without a plan often make emotional '
            'decisions.\n\n'
            'Investors with a strategy understand:\n\n'
            'when to wait;\n'
            'when to invest;\n'
            'when to review their decisions.',
      ),
      MetricInfoSection(
        header: 'The Main Idea',
        body:
            'Successful investing is not about finding one perfect '
            'stock.\n\n'
            'It is about building a system that helps you make '
            'reasonable decisions again and again.\n\n'
            'You cannot control the market.\n\n'
            'But you can control your actions.',
      ),
    ],
  ),
  'investor-score': MetricInfoContent(
    title: 'Psychology & Strategy Scores',
    subtitle: 'Two Sides of Your Investment Behavior',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Do These Widgets Show?',
        body:
            'Your investment behavior is evaluated as two separate '
            'scores, not one blended number.\n\n'
            'They do not measure:\n\n'
            'how much money you made;\n'
            'how fast your portfolio grew;\n'
            'whether you will make a profit in the future.\n\n'
            'Instead, each answers its own question:\n\n'
            '"Psychology Score" — how closely does your behavior '
            'during the test match the habits of a disciplined '
            'investor?\n\n'
            '"Strategy Score" — how well is your portfolio actually '
            'built, independent of how you behaved while building it?',
      ),
      MetricInfoSection(
        header: 'Why Two Scores Instead of One?',
        body:
            'A trader can behave perfectly — no panic selling, no '
            'chasing headlines, plenty of patience — while still '
            'holding a badly built portfolio: everything in one '
            'stock, no cash reserve, no ETFs. The opposite is also '
            'possible: a well-diversified portfolio assembled through '
            'impulsive, emotional trades.\n\n'
            'Blending both into a single number let one side hide '
            'problems on the other. Keeping them separate means each '
            'score tells you something you can actually act on.',
      ),
      MetricInfoSection(
        header: '🧠 PSYCHOLOGY SCORE — Discipline, Panic, Patience',
        body:
            'How you behaved during the test: whether you followed a '
            'plan, how you reacted to market drops, and whether you '
            'gave your decisions time to play out.',
      ),
      MetricInfoSection(
        header: '📊 STRATEGY SCORE — Concentration, ETF Exposure, Cash '
            'Buffer, Sector Balance, Diversification, Safety Marker',
        body:
            'How your portfolio is actually built, right now — '
            'independent of the decisions that got it there.',
      ),
      MetricInfoSection(
        header: '🧩 Diversification — How Your Portfolio Is Built',
        body:
            'This indicator evaluates:\n\n'
            'how your investments are distributed;\n'
            'whether your portfolio depends too heavily on one '
            'company or idea;\n'
            'how well your portfolio is protected from a single '
            'mistake.\n\n'
            'A strong investor understands:\n\n'
            'Owning one great company can be a good decision.\n\n'
            'But building an entire portfolio around one idea creates '
            'unnecessary risk.',
      ),
      MetricInfoSection(
        header: '🧩 Strategy — How You Manage Your Portfolio',
        body:
            'This indicator evaluates:\n\n'
            'asset balance;\n'
            'ETF exposure;\n'
            'cash reserves;\n'
            'risk management.\n\n'
            'A strong strategy helps prevent situations like:\n\n'
            '"I bought everything I liked, and now I don\'t know what '
            'to do next."\n\n'
            'A portfolio is not only about what you own.\n\n'
            'It is also about how you prepare for different market '
            'situations.',
      ),
      MetricInfoSection(
        header: '🧩 Discipline — How You Make Investment Decisions',
        body:
            'This indicator analyzes:\n\n'
            'whether you buy during fear or excitement;\n'
            'whether you follow your strategy;\n'
            'whether your decisions are based on logic or emotions.\n\n'
            'One of the most common investor mistakes is:\n\n'
            'Buying when everyone already feels confident.\n\n'
            'Discipline helps investors search for opportunities '
            'instead of simply following the crowd.',
      ),
      MetricInfoSection(
        header: '🧩 Panic — How You React During Market Declines',
        body:
            'This indicator shows:\n\n'
            'whether you sell under pressure;\n'
            'how you handle market downturns;\n'
            'whether you can separate temporary declines from real '
            'problems.\n\n'
            'Market declines are unavoidable.\n\n'
            'The important question is not:\n\n'
            '"Will the market fall?"\n\n'
            'The important question is:\n\n'
            '"How will I react when it does?"',
      ),
      MetricInfoSection(
        header: '🧩 Patience — Whether You Can Let Time Work',
        body:
            'This indicator evaluates:\n\n'
            'your ability to wait;\n'
            'whether you avoid unnecessary decisions;\n'
            'whether you can stay focused during difficult periods.\n\n'
            'Sometimes the best investment decision is not making a '
            'decision.\n\n'
            'Patience allows good ideas enough time to develop.',
      ),
      MetricInfoSection(
        header: 'How Should You Understand Your Scores?',
        body:
            'The same 5 tiers apply to both scores independently — a '
            '75 Psychology Score and a 75 Strategy Score mean the same '
            'thing about each side of your investing, they just don\'t '
            'have to match each other.\n\n'
            '🔴 0–20 — Beginner Investor\n'
            'Your investment process is currently strongly influenced '
            'by emotions and short-term reactions. The main goal is '
            'not finding perfect investments — the first step is '
            'building strong investment habits.\n\n'
            '🟠 21–40 — Developing Investor\n'
            'You understand many basic investment concepts, but '
            'market situations may still influence some decisions. '
            'The next step: create clear rules and learn to follow '
            'them consistently.\n\n'
            '🟡 41–60 — Balanced Investor\n'
            'You have built a solid foundation. You understand the '
            'importance of strategy and risk management. However, '
            'some market situations may still create pressure.\n\n'
            '🟢 61–80 — Disciplined Investor\n'
            'Your behavior shows strong investment habits. You are '
            'able to control emotions, evaluate risks, and make more '
            'thoughtful decisions.\n\n'
            '⭐ 81–100 — Experienced Investor Mindset\n'
            'Your actions demonstrate a high level of investment '
            'maturity. You understand the importance of long-term '
            'thinking, the power of discipline, and the need for risk '
            'control. However, a high score does not mean '
            'perfection — markets can always surprise investors. The '
            'greatest advantage is the ability to continue making '
            'rational decisions in changing conditions.',
      ),
      MetricInfoSection(
        header: 'The Main Purpose of This Widget',
        body:
            'These scores are not designed to tell you:\n\n'
            '"You are a good investor."\n\n'
            'or\n\n'
            '"You are a bad investor."\n\n'
            'Their purpose is to show:\n\n'
            '"Which investment habits are helping you, and which ones '
            'may limit your long-term progress."\n\n'
            'Every investor can improve both scores.\n\n'
            'Not by trying to predict every market movement.\n\n'
            'But by improving their own decision-making process.',
      ),
      MetricInfoSection(
        header: 'Final Thought',
        body:
            'The market cannot be controlled.\n\n'
            'You cannot control:\n\n'
            'news;\n'
            'prices;\n'
            'economic cycles.\n\n'
            'But you can control:\n\n'
            'your strategy;\n'
            'your decisions;\n'
            'your discipline.\n\n'
            'Your portfolio shows what you own.\n\n'
            'Your Psychology Score shows how you\'re deciding. Your '
            'Strategy Score shows what you\'re building. Together, '
            'they show what kind of investor you are becoming.',
      ),
    ],
  ),
  'psychology-diversification': MetricInfoContent(
    title: 'Diversification',
    subtitle: 'Spreading Risk Across Your Portfolio',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'What Is Diversification?',
        body:
            'Diversification is a way to reduce portfolio risk by '
            'spreading your investments across different assets.\n\n'
            'In simple words:\n\n'
            'Don\'t put all your eggs in one basket.\n\n'
            'If one basket falls, you lose everything.\n\n'
            'But if you have several baskets, a problem with one of '
            'them does not destroy the entire result.\n\n'
            'In investing, this means:\n\n'
            'owning different companies;\n'
            'investing across different industries;\n'
            'avoiding dependence on one single stock.',
      ),
      MetricInfoSection(
        header: 'A Simple Example',
        body:
            'Imagine an investor has \$15,000.\n\n'
            'Scenario 1:\n\n'
            'They invest everything into one company.\n\n'
            'If that company performs well, the results can be '
            'excellent.\n\n'
            'But if the business faces problems, the entire portfolio '
            'suffers together with it.\n\n'
            'One disappointing report.\n\n'
            'One management mistake.\n\n'
            'One unexpected crisis.\n\n'
            'The full impact falls on a single investment.\n\n'
            'Scenario 2:\n\n'
            'The same \$15,000 is distributed across different '
            'companies:\n\n'
            'technology;\n'
            'healthcare;\n'
            'consumer goods;\n'
            'financial services;\n'
            'industrial companies.\n\n'
            'Now, problems in one industry do not necessarily damage '
            'the entire portfolio.\n\n'
            'Some companies may struggle while others continue to '
            'perform well.',
      ),
      MetricInfoSection(
        header: 'But Diversification Is Not Simply Buying Many Stocks',
        body:
            'Many beginner investors think:\n\n'
            '"I own 20 companies, so my portfolio is safe."\n\n'
            'But this is not always true.\n\n'
            'You can own 20 different companies and still have a '
            'highly concentrated portfolio.\n\n'
            'For example:\n\n'
            '20 companies from the artificial intelligence sector.\n\n'
            'Technically, you own many businesses.\n\n'
            'But if the AI industry experiences a major decline, your '
            'entire portfolio may fall at the same time.\n\n'
            'True diversification is not about quantity.\n\n'
            'It is about balance.',
      ),
      MetricInfoSection(
        header: 'What Does This Widget Track?',
        body:
            'This widget analyzes how well your portfolio is '
            'distributed.\n\n'
            'It looks at several important elements:',
      ),
      MetricInfoSection(
        header: 'Number of Companies',
        body:
            'Too few companies can make your portfolio dependent on '
            'only a few decisions.\n\n'
            'But too many companies can turn your portfolio into a '
            'collection of random assets that become difficult to '
            'monitor.',
      ),
      MetricInfoSection(
        header: 'Sector Distribution',
        body:
            'Different industries react differently to economic '
            'conditions.\n\n'
            'When one sector experiences pressure, another may remain '
            'stronger.\n\n'
            'That is why it is important not only to ask:\n\n'
            '"How many companies do I own?"\n\n'
            'But also:\n\n'
            '"What types of businesses and industries do these '
            'companies represent?"',
      ),
      MetricInfoSection(
        header: 'Individual Position Concentration',
        body:
            'Even a strong portfolio can become risky if one company '
            'represents too much of your capital.\n\n'
            'Your favorite company may be an excellent business.\n\n'
            'But even great companies can face unexpected challenges.',
      ),
      MetricInfoSection(
        header: 'The Main Idea',
        body:
            'Good diversification does not mean buying everything.\n\n'
            'It means creating a portfolio where one mistake, one '
            'company, or one industry cannot destroy your entire '
            'investment journey.\n\n'
            'The goal of diversification is not to remove all risk.\n\n'
            'That is impossible.\n\n'
            'The goal is to make risk manageable.',
      ),
    ],
  ),

  // ── Session Complete — Guardian's Verdict full text ──────────────────
  // Reached via "View your analysis" on the Session Complete screen's
  // first card (verdict_screen.dart's _GuardianVerdictSection). Same
  // short-text + expand-to-full-screen pattern as every other "?" info
  // screen.
  'guardian-verdict': MetricInfoContent(
    title: 'GUARDIAN\'S VERDICT',
    subtitle:
        'Congratulations — you have completed your portfolio stress '
        'test.',
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: 'Stress Test Complete',
        body:
            'During the simulation, you experienced different market '
            'periods and scenarios based on patterns observed throughout '
            'real market history. Events that can unfold over months or '
            'even years in the real world were accelerated in the '
            'simulation, allowing you to experience their effects in a '
            'much shorter period of time.\n\n'
            'You saw how your portfolio could behave under very different '
            'conditions:\n\n'
            '📈 Market growth\n'
            '➖ Sideways markets and uncertainty\n'
            '📉 Market declines\n'
            '🔄 Recovery after a downturn\n'
            '🚀 Market hype\n'
            '🎲 Speculative movements\n'
            '⚠️ Crisis scenarios\n'
            '🦢 Rare extreme events and Black Swan scenarios\n\n'
            'Each of these market phases has its own characteristics.\n\n'
            'Hype is not simply a rising price.\n\n'
            'Speculation is not the same as long-term investing.\n\n'
            'A market decline does not automatically mean that a business '
            'is becoming weaker.\n\n'
            'And strong price growth does not automatically mean that an '
            'asset has become a better investment.\n\n'
            'During the test, you have already seen these patterns in '
            'action. Some of them you may have recognized immediately. '
            'Others may have passed unnoticed. That is why one test may '
            'not be enough.\n\n'
            'Try running different stress tests again. Change your '
            'portfolio and observe how your decisions and portfolio '
            'behavior change under different market conditions.\n\n'
            'Over time, you may become better at recognizing different '
            'market phases and understanding why the same action can '
            'have a very different meaning depending on the situation.',
      ),
      MetricInfoSection(
        header: 'One Important Thing to Remember',
        body:
            'Neither in the real world nor in our simulator can anyone '
            'know with certainty which direction the market will take '
            'tomorrow.\n\n'
            'No one can reliably predict: when a period of growth will '
            'end; when a decline will begin; how deep a decline will '
            'become; when recovery will start; which sector will become '
            'the next leader; which unexpected event will change market '
            'sentiment.\n\n'
            'That is why this test is not designed to teach you how to '
            'predict the market. It is designed to teach you something '
            'more useful: how to understand possible market scenarios '
            'and observe your own behavior when they occur.',
      ),
      MetricInfoSection(
        header: 'Train, Don\'t Predict',
        body:
            'Use the simulator as a training environment. Run different '
            'scenarios. Observe your decisions. Watch what happens to '
            'your portfolio as market conditions change.\n\n'
            'Most importantly, learn to recognize the classic mistakes '
            'investors have been studying for decades: chasing hype, '
            'FOMO, poor diversification, excessive concentration, panic '
            'selling, having no cash reserve, constantly trying to time '
            'the market, and making decisions based on emotions.\n\n'
            'And there is an important distinction: this is about '
            'investing, not trading. A trader and a long-term investor '
            'may look at the same market, but their goals, time '
            'horizons, and approaches to risk can be very different. Our '
            'simulator is not designed to teach you to constantly buy '
            'and sell. It is designed to help you understand long-term '
            'investment behavior and develop better decision-making '
            'habits.',
      ),
      MetricInfoSection(
        header: 'Now, Let\'s Look at Your Results',
        body:
            'Below, you will find a detailed analysis of your actions '
            'and your portfolio throughout the simulation. Each '
            'indicator is based on your actual decisions and the events '
            'that occurred during the test.\n\n'
            'The system analyzes: which assets you selected; how '
            'diversified your portfolio was; when you bought; when you '
            'sold; how you behaved during market declines; how '
            'frequently you changed your positions; whether you '
            'demonstrated patience; how you managed risk and your cash '
            'reserve; how closely your behavior matched the principles '
            'of disciplined long-term investing.\n\n'
            'Your actions are processed through an objective algorithmic '
            'analysis that produces individual behavioral indicators and '
            'an overall investor profile.\n\n'
            'This is not about simply telling you "You did this right." '
            'or "You did this wrong." Instead, the system shows: what '
            'happened, why it matters, and which investment skill you '
            'may want to develop further.\n\n'
            'Your result should therefore not be treated as a final '
            'judgment. It is not a prediction of your future financial '
            'results, and it is not a measure of you as a person. It is '
            'a snapshot of your behavior within this particular '
            'simulation.\n\n'
            'And if you don\'t like your result — that\'s actually a '
            'good thing. Because here, you have an opportunity that is '
            'much harder to get in real life: make mistakes in the '
            'simulator, study your decisions, try again, and gradually '
            'learn to recognize and avoid classic investment mistakes '
            'before they become real-world problems.',
      ),
    ],
  ),
};
