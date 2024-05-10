(clear-all)

(define-model morpheme
    
(sgp :esc t :act t)

(chunk-type morpheme morph morphtype gender-retr gender-pred gramcase animacy cat)
(chunk-type word stem suffix word)
(chunk-type process-word stem suffix word step)
(chunk-type process-morpheme morpheme step morphtype gender-retr gender-pred gramcase animacy cat antecedent stem)
(chunk-type antecedent name gender gramcase animacy cat)
(chunk-type possessee name type gender gramcase animacy cat)

(add-dm 
   (stem)(neu)(nom)(anim)(NP)(suffix)(masc)(inanim)(fem)(acc)(picture)(encoding-morpheme)(encoding-stem)(encoding-suffix)(attach)
   (done)(input-suffix)(antecedent-retrieval)(possessee-prediction)
   (sein ISA morpheme morph sein morphtype stem gender-retr masc gender-pred neu gramcase nom animacy anim cat NP)
   (en ISA morpheme morph en morphtype suffix gender-pred masc gramcase acc animacy inanim cat NP)
   (seinen ISA word stem sein suffix en word seinen)
   (Martin ISA antecedent name Martin gender masc gramcase nom animacy anim cat NP)
   (Sarah ISA antecedent name Sarah gender fem gramcase nom animacy anim cat NP)
   (Flasche ISA possessee name Flasche type picture gender fem gramcase acc animacy inanim cat NP)
   (Knopf ISA possessee name Knopf type picture gender masc gramcase acc animacy inanim cat NP)
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
      cat            =cat
==>
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      =morphtype 
      gender-retr    =gend-retr 
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      cat           =cat
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
      step           possessee-prediction
   )


;; Possessee prediction
(p predict-possessee
   =goal>
      ISA            process-morpheme  
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
      step           possessee-prediction
==>
   +retrieval>
      ISA            possessee
      type           picture
      gender         =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
   =goal>
      ISA            process-morpheme
      step           attach
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

;; This production rule fires if the goal buffer matches the slots morpheme and step and morphtype is equal to stem.
;; Then it will retrieve morpheme which has morphtype = suffix and updates the goal buffer with a chunk type called process-word
;; in which the slots stem and step are filled. 
(p input-suffix
   =goal>
      ISA            process-morpheme  
      morpheme       =morph1
      morphtype      stem
      step           input-suffix
==>
   +retrieval> ;; here all the other features such as gender, case etc should be added. 
      ISA            morpheme
      morphtype      suffix
   =goal>
      ISA            process-morpheme
      stem           =morph1
      step           encoding-suffix
   )

(p encode-suffix
   =goal>
      ISA            process-morpheme  
      stem           =morph1
      step           encoding-suffix
   =retrieval> 
      ISA            morpheme
      morph          =morph2
      morphtype      suffix 
      gender-pred    =gend-pred
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
==>
   =goal>
      ISA            process-morpheme  
      morpheme       =morph2
      morphtype      suffix
      gender-pred    =gend-pred 
      gramcase       =gramcase 
      animacy        =anim 
      cat            =cat
      step           possessee-prediction
   )

;; This production rule fires when the goal buffers matches in the slots stem and step
;; and the retrieval buffer matches in the slots morph and morphtype. 
;; Then it retrieves a chunk of type word that matches the stem and the suffix slot
;; and updates the goal buffer, adding the filled slot suffix and the step slot. 
(p attach
   =goal>
      ISA            process-morpheme 
      stem           =morph1
      morpheme       =morph2
      step           attach
==> 
   +imaginal>
      ISA            word
      stem           =morph1
      suffix         =morph2
      word           seinen
   =goal>
      ISA            process-morpheme
      step           done
   )

(goal-focus first-goal)
)
