(clear-all)

(define-model morpheme
    
(sgp :esc t :lf .05 :rt -0.5)

(chunk-type morpheme morph morphtype gender-retr gender-pred gramcase animacy type)
(chunk-type word stem suffix word)
(chunk-type process-word stem suffix word step)
(chunk-type process-morpheme morpheme step morphtype gender-retr gender-pred gramcase animacy type antecedent)
(chunk-type antecedent name gender gramcase animacy type)
(chunk-type possessee object gender gramcase animacy type)

(add-dm 
   (stem)(neu)(nom)(anim)(NP)(suffix)(masc)(inanim)(fem)(acc)(encoding-morpheme)(encoding-stem)(encoding-suffix)(attach)(done)
   (antecedent-retrieval)(possessee-prediction)
   (sein ISA morpheme morph sein morphtype stem gender-retr masc gender-pred neu gramcase nom animacy anim type NP)
   (en ISA morpheme morph en morphtype suffix gender-pred masc gramcase acc animacy inanim type NP)
   (seinen ISA word stem sein suffix en word seinen)
   (Martin ISA antecedent name Martin gender masc gramcase nom animacy anim type NP)
   (Sarah ISA antecedent name Sarah gender fem gramcase nom animacy anim type NP)
   (Flasche ISA possessee object Flasche gender fem gramcase acc animacy inanim type NP)
   (Knopf ISA possessee object Knopf gender masc gramcase acc animacy inanim type NP)
   (first-goal ISA process-morpheme morpheme sein))


;; This production rule fires if the morpheme "sein" is put into the goal buffer and the step slot is empty.
;; which leads to retrieving the corresponding chunk from declaritive memory and adds the step slot to the goal buffer.
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

;; This production rule fires if the morpheme "sein" and the step "encoding-morpheme" is put into the goal buffer
;; and there is a chunk in the retrieval buffer which matches the slot values for morph and morphtype
;; It will then update the goal buffer such that it adds the morphtype and updates the step slot. 
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
      gender-pred    =gend-pred
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
==>
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      =morphtype 
      gender-retr    =gend-retr 
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
      step           antecedent-retrieval
   )

;; Antecedent retrieval
(p retrieve-antecedent
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      stem
      gender-retr    =gend-retr 
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
      step           antecedent-retrieval
==>
   +retrieval>
      ISA            antecedent
      gender         =gend-retr 
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
   =goal>
      ISA            process-morpheme
      step           possessee-prediction
   )


;; Possessee prediction
(p predict-possessee
   =goal>
      ISA            process-morpheme  
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
      step           possessee-prediction
==>
   +retrieval>
      ISA            possessee
      gender         =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      type           =type
   =goal>
      ISA            process-morpheme
      step           encoding-suffix
   )

;; when there is a prediction failure, while retrieving a possessee, then proceed with the suffix. 
(p possessee-retrieval-failure
   =goal>
      ISA            process-morpheme  
      step           possessee-prediction
   ?retrieval>
      buffer         failure
==>
   =goal>
      ISA            process-morpheme
      step           encoding-suffix
   )

;; This production rule fires if the goal buffer matches the slots morpheme and step and morphtype is equal to stem.
;; Then it will retrieve morpheme which has morphtype = suffix and updates the goal buffer with a chunk type called process-word
;; in which the slots stem and step are filled. 
(p encode-suffix
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      stem
      step           encoding-suffix
==>
   +retrieval> ;; here all the other features such as gender, case etc should be added. 
      ISA            morpheme
      morphtype      suffix
   =goal>
      ISA            process-word 
      stem           =morph1
      step           attach
   )

;; This production rule fires when the goal buffers matches in the slots stem and step
;; and the retrieval buffer matches in the slots morph and morphtype. 
;; Then it retrieves a chunk of type word that matches the stem and the suffix slot
;; and updates the goal buffer, adding the filled slot suffix and the step slot. 
(p attach
   =goal>
      ISA            process-word 
      stem           =morph1
      step           attach
   =retrieval>
      ISA            morpheme
      morph          =morph2
      morphtype      suffix
==> 
   +retrieval>
      ISA            word
      stem           =morph1
      suffix         =morph2
   =goal>
      ISA            process-word 
      stem           =morph1
      suffix         =morph2
      step           done
   )

(goal-focus first-goal)
)
