;; Define the model first
(defun define-morpheme-model ()
  (define-model morpheme
    (sgp :esc t :act t :ans .25 :bll 0.5 :ga 1 :lf 0.04
         :rt -1.5 :mp 0.25 :ms 0 :md -1 :dat 0.05
         :egs 0 :mas 3 :trace-detail high)

    ;; Define chunk types
    (chunk-type morpheme morph morphtype gender animacy number)
    (chunk-type word stem suffix word)
    (chunk-type process-morpheme morpheme step morphtype gender animacy number stem cat type)
    (chunk-type noun name gender animacy number cat)
    (chunk-type picture name type gender animacy number cat)

    ;; Add chunks to the declarative memory
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
      (first-goal ISA process-morpheme morpheme sein))

    ;; Define production rules
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
       morpheme          =morph1
       step              "antecedent-retrieval")

    ;; Retrieval of antecedent
    (p encoding-morpheme
       =goal>
       ISA               process-morpheme 
       morpheme          =morph1
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
       =goal> 
       ISA               process-morpheme
       morpheme          nil
       cat               DP 
       gender            =gender 
       animacy           =animacy 
       number            =number
       step              "antecedent-retrieval-check")

    ;; Check whether retrieval is done correctly and predict picture
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
    ==>
       +retrieval>
       ISA               picture
       type              picture
       gender            neu
       animacy           inanim
       number            sg
       =goal>
       ISA               process-morpheme
       cat               nil
       type              picture
       gender            neu
       animacy           inanim
       number            sg
       step              "input-suffix")

    ;; Input of suffix en
    (p input-suffix
       =goal>
       ISA               process-morpheme 
       step              "input-suffix"
    ==>
       +retrieval> 
       ISA               morpheme
       morph             en
       =goal>
       ISA               process-morpheme
       morpheme          en
       type              nil
       gender            nil
       animacy           nil
       number            nil
       step              "possessee-prediction")

    (p picture-prediction-suffix
       =goal>
       ISA               process-morpheme
       morpheme          =morph2
       step              "possessee-prediction"
    ==>
       +retrieval>
       ISA               picture
       type              picture
       gender            masc
       animacy           inanim
       number            sg
       =goal>
       ISA               process-morpheme
       morpheme          nil
       type              picture
       gender            masc
       animacy           inanim
       number            sg
       step              "attach")

    ;; Attach stem and suffix
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
       step              "done"))) ;; End of define-morpheme-model

;; Clear previous definitions and reset the environment
(defun initialize-act-r-environment ()
  (clear-all) ;; Clears the working memory and resets the environment
  (define-morpheme-model)) ;; Define the morpheme model

;; Reset ACT-R model time
(defun reset-act-r-time ()
  (reset)) ;; Resets the ACT-R time to 0

;; Function to capture trace output by redirecting the stream
(defun capture-trace-output (iterations)
  (with-output-to-string (trace-output)
    (initialize-act-r-environment)
    (dotimes (i iterations)
      (reset-act-r-time)
      (format t "Starting simulation iteration ~d~%" (1+ i))
      (with-model morpheme
        (goal-focus first-goal)
        (run 1)) ;; Run a single iteration
      (format t "Finished simulation iteration ~d~%" (1+ i))
      (force-output))
    trace-output)) ;; Return the captured trace

;; Function to run simulations and save trace to file
(defun run-multiple-simulations-and-save-trace (iterations filename)
  (let ((trace (capture-trace-output iterations)))
    (with-open-file filename :direction :output :element-type 'character
                     :if-exists :supersede
                     :external-format :utf-8
                     (lambda (stream)
                       (format stream "Trace output for ~d iterations:~%~a~%" iterations trace)))))

;; Call to run simulations and save trace to file
(run-multiple-simulations-and-save-trace 10 "trace-output.txt")
