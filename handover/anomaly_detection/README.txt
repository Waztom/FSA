Anomalize package was used for anomaly detection.
This website is very useful in describing the packages development and benefit: http://www.business-science.io/code-tools/2018/04/08/introducing-anomalize.html

It was built with tidy way of working in mind, making it scalable and therefore a good choice for the complex networks
There are two time decomposition methods - stl and twitter - I found stl worked better. Twitter had a 'more binary' output - summer or winter - whereas stl was more gradual
For the time decomposition to work you need enough data points therefore there is a filter on countries with 15+ observations

There are two anomaly detection methods - iqr and gesd - I found iqr worked better in picking up what I considered anomalies when looking visually

You can adjust alpha to widen or broaden the acceptable window

Grouping is very important to get the function to work - if looking at one country - ungroup - if multiple then group by country

There are 3 functions - anomaly_detection.R which is for one country, anomaly_detection_all.R which is for all countries and lastly anomaly_detection_all_preloaded.R which references table as running the function in the dashboard was a little slow

I've also included an Rmd which shows the trial and error process I went through