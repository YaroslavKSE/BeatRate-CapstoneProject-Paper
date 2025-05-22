#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= #i18n("analysis-title", lang:option.lang) <sec:analysis>

#option-style(type:option.type)[
  In this section, you perform a State of the Art investigation of your domain to understand what’s been built, how it works, and where it falls short. You’ll survey existing solutions—tools, frameworks and approaches—then compare them against your project’s requirements to justify why a new tool (and its specific feature set) is needed.

A focused Domain Area Research unfolds in these steps:

+ Clarify your research questions and functional requirements
+ Collect and review candidate solutions
+ Evaluate each alternative’s strengths, weaknesses, maturity and architectural style
+ Group similar approaches into meaningful categories (for example, monolithic vs. microservice, commercial vs. open-source)
+ Pinpoint gaps or missing features that motivate your own design

This process carries your initial concept through systematic research all the way to a clear, actionable set of requirements for your proposed tool.
]

#lorem(50)

#add-chapter(
  after: <sec:analysis>,
  before: <sec:design>,
  minitoc-title: i18n("toc-title", lang: option.lang)
)[
  #pagebreak()
  == Section 1

  #lorem(50)

  == Section 2

  #lorem(50)

  == Conclusion

  #lorem(50)
]
