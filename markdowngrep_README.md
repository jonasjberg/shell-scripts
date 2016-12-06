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
    03: "Swedish cat"                           Mjao
    06: "Alternativ svensk katt"                Miau
    09: "International (boredom) distress call" Miaoouuuw
    20: "Suddenly calm"                         Miau
    24: "Catlike"                               Miaoouuuw
    ```

* Match using regular expression. Reads text from standard input.
    ```bash
    $ cat ~/catsay.md | markdowngrep 'M[ij]a[ou]+[w]?'
    03: "Swedish cat"                           Mjao
    06: "Alternativ svensk katt"                Miau
    09: "International (boredom) distress call" Miaoouuuw
    20: "Suddenly calm"                         Miau
    24: "Catlike"                               Miaoouuuw
    ```
    
### Additional options

* Climb to closest level 1 heading.
    ```bash
    $ markdowngrep --level 1 'M[ij]a[ou]+[w]?' ~/catsay.md
    00: "Cats say"      Mjao
    00: "Cats say"      Miau
    00: "Cats say"      Miaoouuuw
    13: "Cats also say" Miau
    13: "Cats also say" Miaoouuuw
    ```

* Climb to closest level 2 heading.
    ```bash
    $ markdowngrep --level 2 'M[ij]a[ou]+[w]?' ~/catsay.md
    0000: "Cats say" Mjao
    0000: "Cats say" Miau
    0000: "Cats say" Miaoouuuw
    ```
