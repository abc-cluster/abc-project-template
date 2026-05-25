(ns src.clerkbook)

(require '[nextjournal.clerk :as clerk])

(clerk/serve! {:browse?     true
               :watch-paths ["notebooks/clerk"]})

(nextjournal.clerk/show! 'nextjournal.clerk.tap)

(tap> (clerk/html [:h1 "Hello 🚰 Tap Inspector 👋"]))

(def clojure-data
  {:hello "world 👋"
   :tacos (map #(repeat % '🌮) (range 1 30))
   :zeta  "The\npurpose\nof\nvisualization\nis\ninsight,\nnot\npictures."})

(tap> clojure-data)


(def fib (lazy-cat [0 1] (map + fib (rest fib))))

(clerk/html [:button.bg-sky-500.hover:bg-sky-700.text-white.rounded-xl.px-2.py-1 "✨ Tailwind CSS"])


(clerk/html [:svg {:width 500 :height 100}
             [:circle {:cx  25 :cy 50 :r 25 :fill "blue"}]
             [:circle {:cx 100 :cy 75 :r 25 :fill "red"}]])


(clerk/table (clerk/use-headers [["odd numbers" "even numbers"]
                                 [1 2]
                                 [3 4]])) ;; seq of seqs with header
