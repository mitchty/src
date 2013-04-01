" Vim syntax file
" Language:	   Clojure
" Last Change: 2008-03-06
" Maintainer:  Toralf Wittner <toralf.wittner@gmail.com>

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

setl iskeyword+=?,-,*,!,+,/,=,<,>

syn match clojureComment ";.*$"
syn match clojureKeyword ":\a[a-zA-Z0-9?!\-+*\./=<>]*"
syn region clojureString start=/"/ end=/"/ skip=/\\"/
syn match clojureCharacter "\\."
syn match clojureCharacter "\\space"
syn match clojureCharacter "\\tab"
syn match clojureCharacter "\\newline"

syn match clojureNumber "\<-\?[0-9]\+\>"
syn match clojureRational "\<-\?[0-9]\+/[0-9]\+\>"
syn match clojureFloat "\<-\?[0-9]\+\.[0-9]\+\([eE][-+]\=[0-9]\+\)\=\>"

syn keyword clojureSyntax fn fn* if def let let* loop* new recur loop do quote the-var identical? throw set! monitor-enter monitor-exit try catch finally in-ns
syn match clojureSyntax "(\s*\(\.\|\.\.\)[^\.]"hs=s+1

syn region clojureDef matchgroup=clojureSyntax start="(\s*\(defmethod\|defmulti\|defmacro\|defstruct\|defn\|def\)\(\s\|\n\)\+"hs=s+1 end="\ze[\[('":)]\|\ze\(#^\)\@<!{" contains=ALLBUT,clojureFunc
syn match clojureDefName "\<[^0-9][a-zA-Z0-9\?!\-\+\*\./<>=]*\>" contained

syn region clojureVector matchgroup=Delimiter start="\[" matchgroup=Delimiter end="\]" contains=ALLBUT,clojureDefName
syn region clojureMap matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=ALLBUT,clojureDefName

syn match clojureNil "\<nil\>"
syn match clojureQuote "\('\|`\)"
syn match clojureUnquote "\(\~@\|\~\)"
syn match clojureDispatch "\(#^\|#'\)"
syn match clojureAnonFn "#\ze("
syn match clojureVarArg "&" containedin=clojureVector
syn keyword clojureBoolean true false

highlight link clojureComment Comment
highlight link clojureString String
highlight link clojureCharacter Character
highlight link clojureNumber Number
highlight link clojureFloat Number
highlight link clojureRational Number
highlight link clojureKeyword PreProc
highlight link clojureSyntax Statement
highlight link clojureDefName Function
highlight link clojureNil Constant
highlight link clojureQuote Macro
highlight link clojureAnonFn Macro
highlight link clojureUnquote Delimiter
highlight link clojureDispatch Constant
highlight link clojureVarArg Number
highlight link clojureBoolean Constant

if exists("g:clj_highlight_builtins")
    "Highlight Clojure's predefined functions"
    syn keyword clojureFunc list cons conj defn instance? vector hash-map sorted-map sorted-map-by defmacro when when-not meta with-meta nil? false? true? not first rest second ffirst rfirst frest rrest = not= str symbol keyword gensym cond seq apply list* fnseq lazy-cons concat and or reduce reverse + * / - < <= > >= == max min inc dec pos? neg? zero? quot rem bit-shift-left bit-shift-right bit-and bit-or bit-xor bit-not complement constantly identity count peek pop nth contains? get assoc dissoc find select-keys keys vals key val rseq name namespace locking .. -> defmulti defmethod remove-method binding find-var agent ! agent-errors clear-agent-errors ref deref commute alter ref-set ensure sync comp partial every? not-every? some not-any? map mapcat filter take take-while drop drop-while cycle split-at split-with repeat replicate iterate range merge merge-with zipmap line-seq comparator sort sort-by eval defimports doseq dorun doall await await-for dotimes import into-array into make-proxy implement pr newline prn print println read with-open doto memfn time int long float double short byte char boolean alength aget aset make-array to-array to-array-2d pmap macroexpand-1 macroexpand create-struct defstruct struct-map struct accessor subvec load resultset-seq set distinct find-ns create-ns remove-ns all-ns ns-name ns-map ns-unmap ns-publics ns-imports refer ns-refers ns-interns take-nth interleave var-get var-set with-local-vars ns-resolve resolve array-map nthrest string? symbol? map? seq? vector? when-first lazy-cat for bean comment with-out-str pr-str prn-str print-str println-str assert test re-pattern re-matcher re-groups re-seq re-matches re-find rand rand-int defn- print-doc find-doc doc tree-seq file-seq xml-seq var? special-symbol? cast class get-proxy-class construct-proxy update-proxy proxy-mappings proxy slurp subs max-key min-key hash-set sorted-set disj
    highlight link clojureFunc Special
endif

let b:current_syntax = "clojure"

