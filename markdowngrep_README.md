`markdowngrep`
==============

Written by Jonas Sjöberg in 2016
<https://github.com/jonasjberg>
<https://jonasjberg.github.io>
`jomeganasatgmaildotcom`




Example usage
-------------

### Usage example text
Text used in usage examples, `~/catsay.md`:

```
H1 Cats say
===========

## H2 Swedish cat
Mjao

## H2 Alternativ svensk katt
Miau

## H2 International (boredom) distress call
Miaoouuuw


H1 Cats also say
================
Mjao

H2 Loudly
---------
MJAAUOO

### H3 Suddenly calm
Miau


H2 Catlike
----------
MIAAOOOO
Miaoouuuw

```


### Basic usage

* Match using regular expression. Reads text from a file path.
    ```bash
    $ markdowngrep 'M[ij]a[ou]+[w]?' ~/catsay.md
     3: H2 Swedish cat                           | Mjao      
     6: H2 Alternativ svensk katt                | Miau      
     9: H2 International (boredom) distress call | Miaoouuuw 
    13: H1 Cats also say                         | Mjao      
    21: H3 Suddenly calm                         | Miau      
    25: H2 Catlike                               | Miaoouuuw
    ```

* Match using regular expression. Reads text from standard input.
    ```bash
    $ cat ~/catsay.md | markdowngrep 'M[ij]a[ou]+[w]?'
     3: H2 Swedish cat                           | Mjao      
     6: H2 Alternativ svensk katt                | Miau      
     9: H2 International (boredom) distress call | Miaoouuuw 
    13: H1 Cats also say                         | Mjao      
    21: H3 Suddenly calm                         | Miau      
    25: H2 Catlike                               | Miaoouuuw
    ```
    
### Additional options

* Climb to heading level 1.
    ```bash
    $ markdowngrep --level 1 'M[ij]a[ou]+[w]?' ~/catsay.md
     0: H1 Cats say      | Mjao      
     0: H1 Cats say      | Miau      
     0: H1 Cats say      | Miaoouuuw 
    13: H1 Cats also say | Mjao      
    13: H1 Cats also say | Miau      
    13: H1 Cats also say | Miaoouuuw
    ```

* Climb to heading level 2.
    ```bash
    $ markdowngrep --level 2 'M[ij]a[ou]+[w]?' ~/catsay.md
     3: H2 Swedish cat                           | Mjao      
     6: H2 Alternativ svensk katt                | Miau      
     9: H2 International (boredom) distress call | Miaoouuuw 
    13: H1 Cats also say                         | Mjao      
    17: H2 Loudly                                | Miau      
    25: H2 Catlike                               | Miaoouuuw
    `
    
* Climb to heading level 3.
    ```bash
    $ markdowngrep --level 3 'M[ij]a[ou]+[w]?' ~/catsay.md
     3: H2 Swedish cat                           | Mjao      
     6: H2 Alternativ svensk katt                | Miau      
     9: H2 International (boredom) distress call | Miaoouuuw 
    13: H1 Cats also say                         | Mjao      
    21: H3 Suddenly calm                         | Miau      
    25: H2 Catlike                               | Miaoouuuw
    ```
