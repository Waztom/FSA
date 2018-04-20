We ended up using the visNetwork package due to its appearance and because of compatibility with R shiny dashboards

Size of arrow and node size depend on trade value
Shape depends on classification of country/node - distributer/consumer/producer - as defined by the a_ratio
Colour is currently set at blue but could depend on the community grouping of countries - via edge.betweenness.communities. Details to add this are in the function. We found this worekd well when looking at an individual plot but confused things when looking at a plot through time or adjusting complexity for example
Threshold/Complexity is based on trade value - e.g. top 25% of trade