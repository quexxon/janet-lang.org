# Generate documentation

(import mendoza/markup-env :as mdz)

(defn- remove-extra-spaces
  "Many docstrings have extra spaces that don't look
  good when formatted. This removes them."
  [str]
  (var ret str)
  (for i 0 10
    (set ret (string/replace "  " " " ret)))
  ret)

(defn- emit-item
  "Generate documentation for one entry."
  [key env-entry]
  (let [{:macro macro
         :value val
         :ref ref
         :source-map sm
         :doc docstring} env-entry
        binding-type (cond
                       macro :macro
                       ref (string :var " (" (type (get ref 0)) ")")
                       (type val))
        docstring (remove-extra-spaces docstring)]
    {:tag "div" "class" "binding"
     :content [{:tag "span" "class" "binding-sym" "id" key :content key} " "
               {:tag "span" "class" "binding-type" :content binding-type} " "
               {:tag "pre" "class" "binding-text" :content (or docstring "")}]}))

(def- all-entries 
  (sort (pairs (table/getproto (fiber/getenv (fiber/current))))))

(defn- get-from-prefix
  "Get all bindings that start with a prefix."
  [prefix]
  (seq [x :in all-entries
        :let [[k entry] x]
        :when (symbol? k)
        :when (get entry :doc)
        :when (not (get entry :private))
        :when (string/has-prefix? prefix k)]
       x))

(defn gen-prefix
  "Generate the document for all of the core api."
  [prefix]
  (def entries (get-from-prefix prefix))
  (def index
    (seq [[k entry] :in entries]
         [{:tag "a" "href" (string "#" k) :content k} " "]))
  (def bindings
    (seq [[k entry] :in entries]
         [{:tag "hr" :no-close true} (emit-item k entry)]))
  [{:tag "p" :content index} bindings])

(defn gen
  "Generate all bindings."
  []
  (gen-prefix ""))
