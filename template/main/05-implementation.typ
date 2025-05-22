#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= Implementation <sec:impl>

#option-style(type:option.type)[
In this section you translate your component-level designs into working code and systems. Focus on the C4 Component layer and on the details needed to show how your design was realized. Include only the most important code snippets that illustrate key patterns or algorithms, rather than full listings.

+ Describe the development methodology (for example, Agile or test-driven development) used to guide your implementation  
+ Explain any prototyping or iterative strategies you applied to refine components before full-scale coding  
+ Summarize coding standards, naming conventions and architectural patterns followed in your codebase  
+ Present critical code snippets or configuration templates that highlight how core components were implemented (for example, key classes, interfaces or algorithms)  
+ Detail your testing approach and quality assurance measures (unit tests, integration tests, coverage metrics)  
+ Note any performance optimizations or profiling results for components that were bottlenecks  
+ Outline your deployment and configuration management process for component artifacts (containerization, CI/CD pipelines)  
+ Highlight documentation deliverables (API references, inline comments, architecture decision records) that support future maintenance  

This section demonstrates how each component specification becomes actual, maintainable code—closing the loop from design to implementation.  
]

#lorem(50)

#add-chapter(
  after: <sec:impl>,
  before: <sec:validation>,
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
