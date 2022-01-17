# Conditional scripts

Suppose that you want to let the user choose the assembler, providing _shovill_
as the default option, but - for example - giving Spades as an alternative.

In DSL1 it was common to put this logic inside the "assembly" process, but it's
probably more readable now to have a _shovill_ process, a _spades_ process, and
then to put the conditional statement in the workflow (or subworkflow) as:

```groovy
    if (params.use_spades){
        assembly = SPADES ( reads )
    } else {
        assembly = SHOVILL( reads )
    }
```