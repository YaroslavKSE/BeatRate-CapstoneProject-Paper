#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= Validation <sec:validation>

#option-style(type:option.type)[
Validation (Requirements Verification and Testing)

In this section you demonstrate how your implementation satisfies the initial requirements through clear testing methods and concise examples—suitable for a bachelor-level project:

+ Restate each key functional and non-functional requirement from your Analysis and Design sections  
+ Describe the testing approach for each requirement (for example, unit tests, manual acceptance checks or scenario walkthroughs)  
+ Provide concrete test cases or usage examples that show how you verify each requirement in practice  
+ Summarize actual versus expected outcomes, indicating pass/fail status for each test  
+ Include brief snippets of test code or sample console outputs to illustrate your procedures  
+ Note any gaps or deviations and suggest simple fixes or areas for future improvement  
+ If a feature wasn’t intended for specific scenarios (e.g. high-load), omit unrealistic stress tests and clearly document its current limitations  

This focused structure ties every requirement directly to validation results, using examples and methods you can realistically carry out at the bachelor level.  

]

#lorem(50)

#add-chapter(
  after: <sec:validation>,
  before: <sec:conclusion>,
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
