;; # Exploring the Palmer Penguins Dataset with Clojure
;;
;; This notebook explores the famous Palmer Penguins dataset using Clojure and Clerk.

^{:nextjournal.clerk/visibility {:code :show :result :show}}
(ns penguins-exploration
  (:require [nextjournal.clerk :as clerk]
            [clojure.data.csv :as csv]
            [clojure.java.io :as io]
            [clojure.string :as str]
            [tablecloth.api :as tc]
            [tech.v3.dataset :as ds]
            [tech.v3.datatype :as dtype]
            #_[scicloj.kindly.v4 :as kindly]
            #_[scicloj.noj.v1.vis.hanami :as hanami]))

(comment
;; start Clerk's built-in webserver on the default port 7777, opening the browser when done
 (clerk/serve! {:browse? true})

 (clerk/serve! {:watch-paths ["notebooks" "clerk"]})

 '())

;; ## Data Loading
;; First, let's download the Palmer Penguins dataset if we don't have it already

^{:nextjournal.clerk/visibility {:code :show :result :hide}}
(def penguins-url "https://raw.githubusercontent.com/allisonhorst/palmerpenguins/master/inst/extdata/penguins.csv")

(defn fetch-penguins-data []
  (let [temp-file (java.io.File/createTempFile "penguins" ".csv")]
    (with-open [in (io/input-stream penguins-url)
                out (io/output-stream temp-file)]
      (io/copy in out))
    temp-file))

(def penguins-file (fetch-penguins-data))

;; Now let's load the data into a dataset
(def penguins
  (-> penguins-file
      (tc/dataset {:key-fn keyword})
      (tc/drop-missing)))
