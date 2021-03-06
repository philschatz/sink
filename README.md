# Baking Markup

[![Codecov](https://img.shields.io/codecov/c/github/philschatz/sink)](https://codecov.io/gh/philschatz/sink)

A [recipe config](./recipe-config.xml) describes what things need to happen to a book.

It is converted into a [recipe](./autogenerated-recipe.xml) which is a tree of replacers.

Each replacer has a selector that matches content and contains 3 sections within its scope:

1. locally-scoped variables: buckets, counters, and the target text for this element when links to it are created
1. any replacers that are nested within the current one
1. what the matched element will be replaced with (can be empty, in which case the element is removed)


# "Tagging Legend" Schema generation

A [book-specific Relax-NG Schema file](./autogenerated-schema.rng) is generated From the [recipe config file](./recipe-config.xml) and the [to-schema.xsl](./to-schema.xsl). See the [validate script](./validate.bash) for how it is generated and validated. [test-module.cnxml](./test-module.cnxml) is a minimal example that fails.


# To-Done

- [x] generate book-specific schema
- [x] replace an element with something defined in the recipe
- [x] inject
    - [x] recipe-defined content at the beginning or end of a matched element (e.g. "Review Questions")
    - [x] counter values (e.g. "4.3")
        - [x] allow-zero-based counting
    - [x] link text defined by the target element (e.g. "See Table 3.27")
    - [x] link text that contains text within the target element (e.g. "See 4.3 Kinematics in Two Dimensions")
    - [x] id attribute to element when it is being linked to
- [x] move
    - [x] elements (Exercises)
    - [x] elements inside elements that are moved (Exercise Answers)
- [x] link
    - [x] to the parent (an Answer links to its Exercise)
    - [x] to a child (an Exercise links to its Answer)
    - [x] to the href target
- [x] group 
    - [x] exercises by section
    - [x] answers by chapter
- [x] wrap the note body (not the title)
- [x] show example [code coverage](https://codecov.io/gh/philschatz/sink)
- [x] show example of mutually exclusive matches (exercise with vs without solution)
    - [ ] error when multiple selectors match an element
- [x] add `<r:chapter-outline>` element that generates the chapter outline
- [ ] update the ToC with links to new sections
- [ ] Index-generation
- [ ] Use a real `inject:` namespace for injected elements & attribs instead of `inject-`
- [x] Re-allow tables and figures to create an os-table wrapper. It is breaking the linking right now.
- [ ] `<r:copy-content>` should squirrel away the values at the beginning instead of at the end

# Prototype

The recipe config file is language agnostic but this repository contains an XSLT implementation.

1. The [recipe config](./recipe-config.xml) + [to-recipe.xsl](./to-recipe.xsl) yields a [recipe](./autogenerated-recipe.xml)
1. The [recipe](./autogenerated-recipe.xml) + [to-xslt.xsl](./to-xslt.xsl) yields [autogenerated.xsl](./autogenerated.xsl)
1. Then, [autogenerated.xsl](./autogenerated.xsl) + [input.xhtml](./input.xhtml) yields [output.xhtml](./output.xhtml)


## Rendered Input and Output

:memo: Here is the **rendered** [input HTML](https://philschatz.com/sink/output.xhtml) and [output HTML](https://philschatz.com/sink/output.xhtml)


# Documentation

## Buckets and Counters

### Bucket

Buckets are declared inside a replacer scope,
items are added to it via the `<r:replacer move-to="...">` attribute,
and its contents is used via a `<r:dump-bucket>`.

**Aside:** declaring the bucket may be unnecessary. The declaration can be inferred.


### Counter

Counters are declared inside a replacer scope via a `<r:counter name="..." selector="..." start-at="1">` and they are
used within that replacer or in nested replacers via a `<r:dump-counter>`.

The `selector="..."` attribute defines when the counter is incremented.
It is automatically reset to `start-at="..."` at the replacer scope.


### Link Text

Additionally, a `<r:link-text>` defines how links to this element should be formatted. 


## Nested Replacers

Replacers are nested which allows them to reuse the lexically-scoped counters and buckets.
As a result, the tree structure of the recipe follows the tree structure of the book.

A nested replacer has a selector that matches descendants of the parent replacer.
Additionally, a nested replacer may have a `move-to=".."` attribute which
defines which bucket the element should be moved into.



## The Resulting Structure

The definition of what is replaced by a replacer is any child 
element inside the replacer that is **not** one of the following:

- `<r:declare>`
- `<r:replacer>`


Usually, this is a `<r:this>` but it can be 0 or more elements (XHTML, `r:this`, `r:children`, ...)

- `<r:this>` is a shallow coppy of the selected element. All of the attributes from the original document are preserved.
- `<r:children>` is the hole where all of the children are injected.
    - `<r:children selector="...">` allows selecting only some children.
- `<r:dump-counter name="...">` is replaced with the current value of the named counter.
- `<r:dump-bucket name="...">` is replaced with the current contents of the named bucket.
- `<r:link>` see the next section for more


## Linking

Automatically creating links still needs some work but for now the current method relies on a few patterns we use in books. We either need to link to a parent (an answer linking back to the exercise) or to a child (the exercise linking to the answer).

Therefore, an link to an exercise solution would look like this: `<r:link to="child" selector="*[data-type='solution']"/>`.

The contents of the link text is either autogenerated by an `<r:link-text>` definition on the link target (e.g. "Figure {ch}.{fig}")
or by what is inside the `<r:link>` element.

Every element may have an `<r:link-text>` definition but this is not necessary.

## Internal links

Content links to other pieces of content will replace the link text with the autogenerated link text (e.g. `<a href="#Figure_4_3"/>`).


## Grouping Collated Elements

Answers at the end of the book are grouped by chapter. Exercises at the end of a chapter are sometimes grouped by which section they occurred in.

Grouping can be done by adding `group-by="*[@data-type='page']"` to `<r:dump-bucket>`.




# Examples

## Move all solutions to the end of the book

To move elements we define the following:

1. a bucket that will be filled (`<r:bucket ...>`)
1. what needs to move (`move-to="..."`)
1. where the contents of the bucket needs to be dumped (`<r:dump-bucket ...>`)

```xml
<r:replace selector="book">
    <r:declare>
        <r:bucket name="solutionBucket"/>
    </r:declare>

    <r:this>
        <r:children/>

        <h2>Answers</h2>
        <r:dump-bucket name="solutionBucket"/>
    </r:this>

    <r:replace move-to="solutionBucket" selector="solution"/>
</r:replace>
```


## Number Exercises

To number exercises, we define a counter which defines when it resets, a selector that defines when it increments, and then we dump the value of the counter into the document.

```xml
<r:replace selector="chapter">
    <r:declare>
        <r:counter start-at="1" name="exerciseCounter" selector="exercise"/>
    </r:declare>

    <!-- replace the book with itself. no changes to attributes but children may change -->
    <r:this/>

    <r:replace selector="exercise">
        <r:this>
            <strong>
                <r:dump-counter name="exerciseCounter"/>.
            </strong>

            <r:children/>
        </r:this>
    </r:replace>
</r:replace>
```


## Create Linktext

A book defines how links to different elements should appear. For example, links to a table should be `Table 4.3`, links to a chapter should be `Chapter 4` and links to a section should be `4.2 Kinematics`. The framework handles finding the links and looking up the elements. Developers only need to specify what text should be used in the link.

In each case the destination defines what the link should look like:

```xml
<r:replace selector="chapter">
    <r:link-text>Chapter <r:dump-counter name="chapterCounter"/></r:link-text>

    <r:replace selector="section">
        <r:link-text><r:dump-counter name="chapterCounter"/>.<r:dump-counter name="sectionCounter"/> <r:children select="title"/></r:link-text>
    
        <r:replace selector="table">
            <r:link-text>Table <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="tableCounter"/></r:link-text>
        <r:replace>

    </r:replace>
</r:replace>
```
