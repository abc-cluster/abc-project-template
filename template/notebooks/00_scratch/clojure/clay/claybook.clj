(ns claybook
  (:require
   [scicloj.kindly.v4.api :as kindly]
   [scicloj.kindly.v4.kind :as kind]
   [scicloj.clay.v2.quarto.highlight-styles :as quarto.highlight-styles]
   [scicloj.clay.v2.quarto.themes :as quarto.themes]
   [scicloj.metamorph.ml.toydata :as toydata]
   [scicloj.tableplot.v1.hanami :as hanami]
   [scicloj.clay.v2.main]
   [tablecloth.api :as tc]
   [clojure.string :as str]))


(comment
  (clay/make! {:source-path ["notebooks/src/claybook.clj"]
               :live-reload true})

  (clay/make! {:format      [:quarto :html]
               :source-path "notebooks/src/claybook.clj"
               :base-target-path "notebooks/output/"
               :clean-up-target-dir true
               :quarto      {:highlight-style :nord
                             :format          {:html {:theme :journal}}}})

  '())




(-> (toydata/iris-ds)
    (hanami/plot hanami/rule-chart
                 {:=x            :sepal-width
                  :=x2           :sepal-length
                  :=y            :petal-width
                  :=y2           :petal-length
                  :=color        :species
                  :=color-type   :nominal
                  :=mark-size    3
                  :=mark-opacity 0.2}))
