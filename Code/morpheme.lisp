(clear-all)

(define-model morpheme
    
(sgp :esc t :act t :ans .2 :bll 0.5 :ga 1 :lf 0.04 :rt -1.5 :mp 0.25 :ms 0 :md -1 :dat 0.05 :egs 0 :mas 3 :trace-detail high)
;; ans recommended range is [.2;.8]

(chunk-type morpheme morph morphtype gender-retr gender-pred gramcase gramcase-pred animacy animacy-pred cat cat-pred)
(chunk-type word stem suffix word)
(chunk-type process-word stem suffix word step)
(chunk-type process-morpheme morpheme step morphtype gender-retr gender-pred gramcase gramcase-pred animacy animacy-pred cat cat-pred stem)
(chunk-type antecedent name gender gramcase animacy cat)
(chunk-type possessee name type gender gramcase animacy cat)

(add-dm 
   (stem)(neu)(nom)(anim)(NP)(suffix)(masc)(inanim)(fem)(acc)(picture)(encoding-morpheme)(encoding-stem)(encoding-suffix)(attach)
   (done)(input-suffix)(antecedent-retrieval)(possessee-prediction)
   ;; sein now includes the features relevant for retrieval and prediction
   (sein ISA morpheme morph sein morphtype stem gender-retr masc gender-pred neu gramcase nom gramcase-pred acc animacy anim animacy-pred inanim
      cat NP cat-pred NP)
   (en ISA morpheme morph en morphtype suffix gender-pred masc gramcase-pred acc animacy-pred inanim cat-pred NP)
   (seinen ISA word stem sein suffix en word seinen)
   (Martin ISA antecedent name Martin gender masc gramcase nom animacy anim cat NP)
   (Sarah ISA antecedent name Sarah gender fem gramcase nom animacy anim cat NP)
   (Flasche ISA possessee name Flasche type picture gender fem gramcase acc animacy inanim cat NP)
   (Knopf ISA possessee name Knopf type picture gender masc gramcase acc animacy inanim cat NP)
   (first-goal ISA process-morpheme morpheme sein))

;; Input of sein.
(p input-morpheme
   =goal>
      ISA            process-morpheme
      morpheme       =morph1
      step           nil
==>
   +retrieval>
      ISA            morpheme
      morph          =morph1
   =goal>
      ISA            process-morpheme 
      morpheme       =morph1
      step           encoding-morpheme
   )

;; Encoding of sein.
(p encode-morpheme
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      step           encoding-morpheme
   =retrieval> 
      ISA            morpheme
      morph          =morph1
      morphtype      =morphtype
      gender-retr    =gend-retr 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
      gender-pred    =gend-pred 
      gramcase-pred  =gramcase-pred 
      animacy-pred   =animacy-pred 
      cat-pred       =cat-pred 
==>
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      =morphtype 
      gender-retr    =gend-retr 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
      gender-pred    =gend-pred 
      gramcase-pred  =gramcase-pred 
      animacy-pred   =animacy-pred 
      cat-pred       =cat-pred 
      step           antecedent-retrieval
   )

;; Antecedent retrieval
(p retrieve-antecedent
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      =morphtype
      gender-retr    =gend-retr 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
      step           antecedent-retrieval
==>
   +retrieval>
      ISA            antecedent
      gender         =gend-retr 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
   =goal>
      ISA            process-morpheme
      step           possessee-prediction ;; this is already considered as context during retrieval
   )


;; All features from the retrieval are still in the goal buffer


;; Possessee prediction
(p predict-possessee
   =goal>
      ISA            process-morpheme
      ;; morpheme       =morph 
      gender-pred    =gend-pred 
      gramcase-pred  =gramcase-pred
      animacy-pred   =anim-pred
      cat-pred       =cat-pred
      step           possessee-prediction
==>
   +retrieval>
      ISA            possessee
      type           picture
      gender         =gend-pred 
      gramcase       =gramcase-pred 
      animacy        =anim-pred 
      cat            =cat-pred
   +goal>   ;; this cannot be the solution, since it creates a new slot
      ISA            process-morpheme
      morphtype      suffix
      ;; morpheme       =morph 
      step           input-suffix
   )

;; when there is a prediction failure, while retrieving a possessee, then proceed with the suffix. 
(p possessee-retrieval-failure
   =goal>
      ISA            process-morpheme  
      step           attach
   ?retrieval>
      buffer         failure
==>
   =goal>
      ISA            process-morpheme
      step           input-suffix
   )

;; Input of en. 
(p input-suffix
   =goal>
      ISA            process-morpheme 
      morphtype      suffix
      step           input-suffix
   =retrieval>
      ISA            possessee
      type           picture
==>
   +retrieval> 
      ISA            morpheme
      morphtype      suffix
      ;;:recently-retrieved nil

   =goal>
      ISA            process-morpheme
      step           encoding-suffix
   )

;; Encoding of en. 
(p encode-suffix
   =goal>
      ISA            process-morpheme  
      morphtype      suffix
      step           encoding-suffix
   =retrieval> 
      ISA            morpheme
      morph          =morph2
      morphtype      suffix 
      gender-pred    =gend-pred
      gramcase       =gramcase-pred 
      animacy        =anim-pred 
      cat            =cat-pred
==>
   =goal>
      ISA            process-morpheme  
      morpheme       =morph2
      morphtype      suffix
      gender-pred    =gend-pred 
      gramcase-pred  =gramcase-pred 
      animacy-pred   =anim-pred
      cat-pred       =cat-pred
      step           possessee-prediction
   )

;; this still needs to be connected such that it takes place after the second prediction production
(p attach
   =goal>
      ISA            process-morpheme 
      morpheme       en ;;does this makes sense?
      step           input-suffix
==> 
   +retrieval> ;;retrieve something that is a word and has suffix en
      ISA            word
      suffix         en
   =goal>
      ISA            process-morpheme
      step           done
   )

(goal-focus first-goal)
)
