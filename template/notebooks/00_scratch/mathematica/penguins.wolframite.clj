(ns penguins.wolframite
  (:require
   [clojure.set :as set]
   [clojure.string :as str]
   [wolframite.api.v1 :as wl]
   [wolframite.core :as wc]
   [wolframite.lib.helpers :as h]
   [wolframite.runtime.defaults :as defaults]
   [wolframite.tools.hiccup :as wh]
   [wolframite.wolfram :as w :refer :all
    :exclude [* + - -> / < <= = == > >= fn
              Byte Character Integer Number Short String Thread]]
   [scicloj.kindly.v4.kind :as k]))

;; Initialize Wolfram Engine
(wl/start!)


(comment

  (w/)

  '())
;; # Data Analysis of Palmer Penguins with Wolframite
;; This notebook performs data analysis on the Palmer Penguins dataset using Clojure and Wolframite.

;; --- Configuration ---
(def data-path "/Users/abhi/projects/scratch-palmer-penguins/analysis/data/01_raw/palmerpenguins_extended.csv")

;; --- Data Loading ---
;; Load dataset and handle missing values
(def penguins-raw
  (wl/! (w/Import data-path)))

;; Convert to Dataset and remove missing values
(def penguins
  (wl/! (w/DeleteMissing (w/Dataset penguins-raw))))

;; --- Initial Exploration ---

;; Get dimensions (rows, columns)
(wl/! (w/Dimensions penguins))

;; Display first 5 rows
(wl/! (w/Take penguins 5))

;; Get column names
(def headers
  (wl/! (w/Normal (w/Part (w/Import data-path "CSV") 1))))

;; Define column groups
(def numerical-cols ["bill_length_mm" "bill_depth_mm" "flipper_length_mm" "body_mass_g"])
(def categorical-cols ["species" "island" "sex"])

;; --- Basic Statistics ---

;; Summary statistics for numerical columns
(wl/!
 (w/Map
  (fn [col]
    (w/Association
     (w/Rule "Column" col)
     (w/Rule "Mean" (w/Mean (w/Normal (w/Part penguins w/All col))))
     (w/Rule "Median" (w/Median (w/Normal (w/Part penguins w/All col))))
     (w/Rule "StdDev" (w/StandardDeviation (w/Normal (w/Part penguins w/All col))))
     (w/Rule "Min" (w/Min (w/Normal (w/Part penguins w/All col))))
     (w/Rule "Max" (w/Max (w/Normal (w/Part penguins w/All col))))
     (w/Rule "MissingCount" (w/Count (w/Select (w/Normal (w/Part penguins w/All col)) w/MissingQ)))))
  numerical-cols))

;; --- Categorical Analysis ---

;; Frequency counts for categorical variables
(wl/!
 (w/Map
  (fn [col]
    (w/Association
     (w/Rule "Column" col)
     (w/Rule "Counts" (w/Counts (w/Normal (w/Part penguins w/All col))))))
  categorical-cols))

;; --- Correlation Analysis ---

;; Correlation matrix for numerical variables
(def correlation-matrix
  (wl/!
   (w/Correlation (w/Normal (w/Part penguins w/All numerical-cols)))))

;; --- Grouped Statistics ---

;; Summary statistics by species
(wl/!
 (w/Dataset
  (w/GroupBy penguins (w/Function (w/Part w/# "species"))
             (w/Function
              (w/Association
               (w/Map (fn [col]
                       (w/Rule col
                              (w/Association
                               (w/Rule "Mean" (w/Mean (w/Normal (w/Part w/# w/All col))))
                               (w/Rule "StdDev" (w/StandardDeviation (w/Normal (w/Part w/# w/All col))))
                               (w/Rule "Min" (w/Min (w/Normal (w/Part w/# w/All col))))
                               (w/Rule "Max" (w/Max (w/Normal (w/Part w/# w/All col)))))))
                     numerical-cols))))))

;; Cross tabulation of species and island
(wl/!
 (w/Dataset
  (w/GroupBy penguins (w/Function (w/List (w/Part w/# "species") (w/Part w/# "island")))
             (w/Function (w/Length w/#)))))

;; Cross tabulation of species and sex
(wl/!
 (w/Dataset
  (w/GroupBy penguins (w/Function (w/List (w/Part w/# "species") (w/Part w/# "sex")))
             (w/Function (w/Length w/#)))))

(comment
  ;; Example of direct Wolfram Language evaluation
  (wl/! (w/Dot [1 2 3] [4 5 6]))

  ;; Restart Wolfram Engine if needed
  (wl/restart!)

  '())
