(clear-all)

(define-model morpheme
    
(sgp :esc t :act t :ans .25 :bll 0.5 :ga 1 :lf 0.04 :rt -1.5 :mp 0.25 :ms 0 :md -1 :dat 0.05 :egs 0 :mas 3 :trace-detail high)

(chunk-type morpheme morph morphtype gender gender-possessee animacy animacy-possessee number number-possessee)
(chunk-type word stem suffix word)
(chunk-type process-word stem suffix word step)
(chunk-type process-morpheme morpheme step morphtype gender gender-possessee animacy animacy-possessee number number-possessee stem)
(chunk-type antecedent name gender animacy number)
(chunk-type possessee name type gender animacy number)

(add-dm 
   (stem)(neu)(anim)(sg)(suffix)(masc)(inanim)(fem)(picture)(encoding-morpheme)(encoding-stem)(encoding-suffix)(attach)(encode-morpheme-pred)
   (done)(input-suffix)(antecedent-retrieval)(possessee-prediction)(antecedent-retrieval-check)
   ;; sein now includes the features relevant for retrieval and prediction
   (sein ISA morpheme morph sein morphtype stem gender masc gender-possessee neu animacy anim animacy-possessee inanim
      number sg number-possessee sg)
   (en ISA morpheme morph en morphtype suffix gender-possessee masc animacy-possessee inanim number-possessee sg)
   (seinen ISA word stem sein suffix en word seinen)
   (Martin ISA antecedent name Martin gender masc animacy anim number sg)
   (Sarah ISA antecedent name Sarah gender fem animacy anim number sg)
   (Flasche ISA possessee name Flasche type picture gender fem animacy inanim number sg)
   (Knopf ISA possessee name Knopf type picture gender masc animacy inanim number sg)
   (first-goal ISA process-morpheme morpheme sein))

;; Input of sein.
(p input-morpheme
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      step              nil
==>
   +retrieval>
      ISA               morpheme
      morph             =morph1
   =goal>
      ISA               process-morpheme 
      morpheme          =morph1
      step              encoding-morpheme
   )

;; Encoding of sein.
(p encode-morpheme-retrieval
   =goal>
      ISA               process-morpheme  
      morpheme          =morph1
      step              encoding-morpheme
   =retrieval> 
      ISA               morpheme
      morph             =morph1
      morphtype         =morphtype
      gender            =gender 
      animacy           =anim 
      number            =number
      gender-possessee  =gender-possessee 
      animacy-possessee =animacy-possessee 
      number-possessee  =num-possessee 
==>
   =goal>
      ISA               process-morpheme  
      morpheme          =morph1
      morphtype         =morphtype 
      gender            =gender 
      animacy           =anim 
      number            =number
      gender-possessee  nil 
      animacy-possessee nil 
      number-possessee  nil
      step              antecedent-retrieval
   )

;; Antecedent retrieval
(p retrieve-antecedent
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      morphtype         =morphtype
      gender            =gender 
      animacy           =anim 
      number            =number
      step              antecedent-retrieval
==>
   +retrieval>
      ISA               antecedent
      gender            =gender 
      animacy           =anim 
      number            =number
      :recently-retrieved nil ;; without that "sein" is retrieved, because it has a high base-level activation.
      ;; I guess the left corner parser is responsible here for not retrieving sein, but Martin?
   =goal> ;; remove features for prediction and update step slot
      ISA               process-morpheme

      step              antecedent-retrieval-check 
   )

;; check whether retrieval is done
(p retrieve-antecedent-check
   =retrieval>
      ISA               antecedent  
      gender            =gender 
      animacy           =anim 
      number            =number
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      morphtype         =morphtype
      step              antecedent-retrieval-check

==>
   +retrieval>
      ISA               morpheme
      morph             =morph1
      morphtype         =morphtype 
      gender            =gender 
      animacy           =anim 
      number            =number

   =goal>
      ISA               process-morpheme
      step              encode-morpheme-pred
   )

;; encode morpheme for prediction
(p encode-morpheme-prediction
   =retrieval>
      ISA               morpheme
      morph             =morph1
      morphtype         =morphtype 
      gender            =gender 
      animacy           =anim 
      number            =number
      gender-possessee  =gender-possessee 
      animacy-possessee =animacy-possessee 
      number-possessee  =num-possessee 
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      morphtype         =morphtype
      step              encode-morpheme-pred
==>
   =goal>
      ISA               process-morpheme
      gender            nil
      animacy           nil
      number            nil
      gender-possessee  =gender-possessee 
      animacy-possessee =animacy-possessee 
      number-possessee  =num-possessee 
      step              possessee-prediction
   )


;; Possessee prediction
(p predict-picture
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      morphtype         =morphtype
      gender-possessee  =gender-possessee 
      animacy-possessee =animacy-possessee 
      number-possessee  =num-possessee 
      step              possessee-prediction
==>
   +retrieval>
      ISA               possessee
      type              picture
      gender            =gender-possessee 
      animacy           =animacy-possessee 
      number            =num-possessee
   =goal>   
      ISA               process-morpheme
      morphtype         =morphtype
      step              input-suffix
   )

;; when there is a prediction failure, while retrieving a picture, then proceed with the suffix. 
(p picture-retrieval-failure
   =goal>
      ISA               process-morpheme  
      step              attach
   ?retrieval>
      buffer            failure
==>
   =goal>
      ISA               process-morpheme
      step              input-suffix
   )

;; Input of suffix en. 
(p input-suffix
   =goal>
      ISA               process-morpheme 
      morphtype         stem
      step              input-suffix
   =retrieval>
      ISA               possessee
      type              picture
==>
   +retrieval> 
      ISA               morpheme
      morphtype         suffix
      ;;:recently-retrieved nil

   =goal>
      ISA               process-morpheme
      morphtype         suffix
      morpheme          nil
      gender-possessee  nil 
      animacy-possessee nil 
      number-possessee  nil
      step              encoding-suffix
   )

;; Encoding of en. 
(p encode-suffix
   =goal>
      ISA               process-morpheme  
      morphtype         suffix
      step              encoding-suffix
   =retrieval> 
      ISA               morpheme
      morph             =morph2
      morphtype         suffix 
      gender-possessee  =gender-possessee
      animacy-possessee =animacy-possessee 
      number-possessee  =num-possessee
==>
   =goal>
      ISA               process-morpheme  
      morpheme          =morph2
      morphtype         suffix
      gender-possessee  =gender-possessee  
      animacy-possessee =animacy-possessee
      number-possessee  =num-possessee
      step              possessee-prediction
   )

;; attach stem and suffix
(p attach
   =goal>
      ISA               process-morpheme 
      morphtype         suffix 
      morpheme          =morph2
      step              input-suffix
==> 
   +retrieval> ;;retrieve something that is a word and has suffix en
      ISA               word
      ;;stem              =morph1 how to put "sein" here?
      suffix            =morph2
   =goal>
      ISA               process-morpheme
      step              done
   )

(goal-focus first-goal)
)
