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
  const MetricInfoContent({
    required this.title,
    required this.subtitle,
    required this.sections,
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
  // Financial Score's 6 markers (financial_score_widget.dart) — content
  // not written yet, so none of these show a "?" until an entry exists
  // in metricInfoRegistry below.
  'Valuation': 'valuation',
  'Financial Health': 'financial-health',
  'Growth Potential': 'growth-potential',
  'Efficiency': 'efficiency',
  'Historical Trend': 'historical-trend',
  'Capital Return': 'capital-return',
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
        header: 'Can a company have a 0% Dividend Yield and still be '
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
        header: 'How is Gross Margin different from Operating Margin and '
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
        header: 'Why Warren Buffett pays close attention to ROE',
        body:
            'Legendary investor Warren Buffett has often favored '
            'companies that consistently generate high ROE over many '
            'years.\n\n'
            'Why? Because consistently high ROE may indicate: strong '
            'management, durable competitive advantages, efficient use of '
            'capital, and a business capable of generating long-term '
            'value for shareholders.\n\n'
            'However, Buffett also emphasizes that high ROE should always '
            'be supported by reasonable debt levels.',
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
};
