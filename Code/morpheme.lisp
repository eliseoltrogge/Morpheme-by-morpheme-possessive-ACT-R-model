(clear-all)

(define-model morpheme
    
(sgp :esc t :act t :ans .25 :bll 0.5 :ga 1 :lf 0.04 :rt -1.5 :mp 0.25 :ms 0 :md -1 :dat 0.05 :egs 0 :mas 3 :trace-detail high)

(chunk-type morpheme morph morphtype gender animacy number)
(chunk-type word stem suffix word)
;;(chunk-type process-word stem suffix word step)
(chunk-type process-morpheme morpheme step morphtype gender animacy number stem cat type)
(chunk-type noun name gender animacy number cat) ;; maybe rename noun in the future
(chunk-type picture name type gender animacy number cat)

(add-dm 
   (stem)(neu)(anim)(sg)(suffix)(masc)(inanim)(fem)(picture)(encoding)(encoding-stem)(encoding-suffix)(attach)(encode-morpheme-pred)
   (done)(input-suffix)(antecedent-retrieval)(possessee-prediction)(antecedent-retrieval-check)(DP)
   (sein ISA morpheme morph sein morphtype stem gender masc animacy anim number sg)
   (en ISA morpheme morph en morphtype suffix)
   (seinen ISA word stem sein suffix en word seinen)
   (Martin ISA noun name Martin gender masc animacy anim number sg cat DP)
   (Sarah ISA noun name Sarah gender fem animacy anim number sg cat DP)
   (Flasche ISA picture name Flasche type picture gender fem animacy inanim number sg cat DP)
   (Knopf ISA picture name Knopf type picture gender masc animacy inanim number sg cat DP)
   (first-goal ISA process-morpheme morpheme sein)
   )

;; Input of sein.
(p input-morpheme
   =goal>
      ISA               process-morpheme
      morpheme          =morph1
      step              nil
==>
   +retrieval> ;; this is a hack to input the stem.
      ISA               morpheme
      morph             =morph1
   =goal>                      
      morpheme          =morph1
      step              "antecedent-retrieval" 
   )

;; Retrieval of antecedent. 
(p encoding-morpheme
   =goal>
      ISA               process-morpheme 
      step              "antecedent-retrieval"
   =retrieval> 
      ISA               morpheme
      morph             =morph1
      morphtype         =morphtype
      gender            =gender 
      animacy           =animacy 
      number            =number
==>
   +retrieval>
      ISA               noun
      cat               DP 
      gender            =gender 
      animacy           =animacy 
      number            =number
   +goal> 
      ISA               process-morpheme
      cat               DP 
      gender            =gender 
      animacy           =animacy 
      number            =number
      step              "antecedent-retrieval-check" 
   )


;; Check whether retrieval is done correctly 
;; and if so predict picture. 
(p predict-picture-stem
   =retrieval>
      ISA               noun
      cat               DP
      gender            =gender 
      animacy           =anim 
      number            =number
   =goal>
      ISA               process-morpheme
      step              "antecedent-retrieval-check"
==> ;; predict picture
   +retrieval>
      ISA               picture
      type              picture
      gender            neu
      animacy           inanim
      number            sg
   +goal>
      ISA               process-morpheme
      type              picture
      gender            neu
      animacy           inanim
      number            sg
      ;;stem              sein ;; not sure how to put the stem here. 
      step              "input-suffix"
   )

;; Input of suffix en. 
(p input-suffix
   =goal>
      ISA               process-morpheme 
      ;;stem              sein
      step              "input-suffix"
==>
   +retrieval> 
      ISA               morpheme
      morph             en
   +goal>
      ISA               process-morpheme
      morpheme          en
      step              "possessee-prediction"
   )

(p picture-prediction-suffix
   =goal>
      ISA               process-morpheme
      morpheme          =morph2
      step              "possessee-prediction"
==> ;; predict picture
   +retrieval>
      ISA               picture
      type              picture
      gender            masc
      animacy           inanim
      number            sg
   +goal>
      ISA               process-morpheme
      type              picture
      gender            masc
      animacy           inanim
      number            sg
      step              "attach"
   )

;; attach stem and suffix
(p attach
   =goal>
      ISA               process-morpheme 
      step              "attach"
==> 
   +retrieval> 
      ISA               word
      stem              sein 
      suffix            en
   =goal>
      ISA               process-morpheme
      step              "done"
   )

(goal-focus first-goal)
)
