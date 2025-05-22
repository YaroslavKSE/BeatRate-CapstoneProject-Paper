#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= #i18n("design-title", lang:option.lang) <sec:design>

#option-style(type:option.type)[
In this section you turn your requirements into a concrete engineering blueprint. You’ll justify every major architectural choice, visualize structure with C4 diagrams for the first three layers, and map out your runtime topology so that peers can understand—and you can defend—every aspect of your system.

+ Clarify how functional and non-functional requirements drive your high-level architecture  
+ List each architectural decision (for example, “We chose microservices to enable independent scaling and deployment”) and explain why it best meets your goals  
+ Include a C4 Context diagram showing your system in its environment (users, external systems, data sources)  
+ Include a C4 Container diagram breaking the system into deployable units (APIs, web front end, background workers, databases) and annotate communication styles and protocols  
+ Include a C4 Component diagram for your core container(s), illustrating key modules, services or libraries and their interactions  
+ Describe your deployment topology: physical or cloud hosts, network zones, load-balancing, failover and backup strategies  
+ Summarize your technology stack, mapping each tool or framework back to a specific container or component and noting any trade-offs (performance, community support, learning curve)  
+ Outline how data flows through the system—including storage models, messaging patterns or API contracts—and note any schema or interface versioning plans  
+ Address cross-cutting concerns (Security, Logging, Monitoring, Scalability) and show where they sit in your topology  

By walking through Requirements → Decisions → Diagrams → Topology, your Design section becomes a rigorous, evidence-backed foundation for the implementation that follows.  

]

#lorem(50)

#add-chapter(
  after: <sec:design>,
  before: <sec:impl>,
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
