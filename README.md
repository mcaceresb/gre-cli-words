Description
-----------

Study GRE vocab from the command line, including the strength and positive/negative connotation of the word if available. Note I use [Julia](http://julialang.org) to compile the list of words from source.

Setup
-----

```bash
mkdir $HOME/lib
cd $HOME/lib
git clone github.com/mcaceresb/gre-cli-words
cd gre-cli-words
chmod +x ./generate_gre_words.jl
./generate_gre_words.jl
./random_gre.sh $HOME/lib/gre-cli-words/custom_gre_word_list
echo "$HOME/lib/random_gre.sh $HOME/lib/gre-cli-words/custom_gre_word_list" >> $HOME/.bashrc
```

The last line makes it so a random word appears whenever you open a terminal running bash.

Sample output
-------------

```bash
eschew - strong, negative
         (verb) to abstain or keep away from
         (verb) to shun or avoid
```

Sources
-------

[Practice GRE Vocabulary Words from Quizlet](https://quizlet.com/144195604/500-practice-gre-vocabulary-words-flash-cards)

[MPQA lexicons](http://mpqa.cs.pitt.edu), in particular the [Subjectivity Lexicon](http://mpqa.cs.pitt.edu/lexicons/subj_lexicon) (Wilson et al., 2005) and the [Effect Lexicon](http://mpqa.cs.pitt.edu/lexicons/effect_lexicon) (Choi and Wiebe, 2014).

Theresa Wilson, Janyce Wiebe and Paul Hoffmann (2005). Recognizing Contextual Polarity in Phrase-Level Sentiment Analysis. Proceedings of HLT/EMNLP 2005, Vancouver, Canada.

Yoonjung Choi and Janyce Wiebe (2014). +/-EffectWordNet: Sense-level Lexicon Acquisition for Opinion Inference. EMNLP 2014.
