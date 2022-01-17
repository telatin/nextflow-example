# Conditionals


## Alternative modules

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
    abricate(assembly)
```

:bulb: Note that we will not use SPADES.out (or SHOVILL.out) as input for abricate,
but simply "assembly", as it is populated with the output of the process.

### Running the script using SPAdes

```bash
nextflow run first-steps/conditional-processes/main.nf --use_spades --input 
```


## Conditional module execution

Inside a module you can add a `when:` directive can allow skipping
the execution of a module, [as described in the docs](https://www.nextflow.io/docs/latest/process.html#when).


Example from the documentation:

```groovy
process find {
  input:
  file proteins
  val type from dbtype

  when:
  proteins.name =~ /^BB11.*/ && type == 'nr'

  script:
  """
  blastp -query $proteins -db nr
  """

}
```