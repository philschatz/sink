# Baking Markup

A [recipe config](./recipe.xml) describes a tree of replacers.

Each replacer has a selector that matches content and contains 3 sections within its scope:

1. locally-scoped buckets and counters
2. any replacers that are nested within the current one
3. what the matched element will be replaced with


# Prototype

The recipe config file is language agnostic but this recipe contains an XSLT implementation.

The [recipe config](./recipe.xml) + [to-xslt.xsl](./to-xslt.xsl) yields [autogenerated.xsl](./autogenerated.xsl)

Then, [autogenerated.xsl](./autogenerated.xsl) + [input.xhtml](./input.xhtml) yields [output.xhtml](./output.xhtml)


# Buckets and Counters

## Bucket

Buckets are declared inside a replacer scope,
items are added to it via the `<r:replacer move-to="...">` attribute,
and its contents is used via a `<r:dump-bucket>`.

**Aside:** declaring the bucket may be unnecessary. The declaration can be inferred.


## Counter

Counters are declared inside a replacer scope and they are
used within that replacer or in nested replacers via a `<r:dump-counter>`.

The `selector="..."` attribute defines when the counter is incremented.
It is automatically reset at the replacer scope.


## Link Text

Additionally, a `<r:link-text>` defines how links to this element should be formatted. 


# Nested Replacers

Replacers are nested which allows them to reuse the lexically-scoped counters and buckets.
As a result, the tree structure of the recipe follows the tree structure of the book.

A nested replacer has a selector that matches descendants of the parent replacer.
Additionally, a nested replacer may have a `move-to=".."` attribute which
defines which bucket the element should be moved into.



# The Resulting Structure

The definition of what is replaced by a replacer is any child 
element inside the replacer that is **not** one of the following:

- `<r:bucket>`
- `<r:counter>`
- `<r:replacer>`
- `<r:link-text>`


Usually, this is a `<r:this>` but it can be 0 or more elements (XHTML, `r:this`, `r:children`, ...)

- `<r:this>` is a shallow coppy of the selected element. All of the attributes from the original document are preserved.
- `<r:children>` is the hole where all of the children are injected.
- `<r:dump-counter name="...">` is replaced with the current value of the named counter.
- `<r:dump-bucket name="...">` is replaced with the current contents of the named bucket.
- `<r:link>` see the next section for more


# Linking

Automatically creating links still needs some work but for now the current method relies on a few patterns we use in books. We either need to link to a parent (an answer linking back to the exercise) or to a child (the exercise linking to the answer).

Therefore, an link to an exercise solution would look like this: `<r:link to="child" selector="*[data-type='solution']"/>`.

The contents of the link text is either autogenerated by an `<r:link-text>` definition on the link target (e.g. "Figure {ch}.{fig}")
or by what is inside the `<r:link>` element.

Every element may have an `<r:link-text>` definition but this is not necessary.


### TODO: Other types of links

- ToC links to autogenerated pages
- Section headers when exercises are grouped by section
- A content link pointing to other content (e.g. `<a href="#Figure_4_3"/>`)

# Unimplemented

- Updating the ToC with links to new sections
- Grouping exercises by section
- Index-generation