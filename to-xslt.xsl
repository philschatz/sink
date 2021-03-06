<!--

Helpful references:

XSLT3.0: https://www.w3.org/TR/xslt-30/
XPath functions: https://www.w3.org/TR/xpath-functions-30/

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:t="http://www.w3.org/1999/XSL/TransformAlias"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:r="urn:replacer-xml"
    xmlns:temp="urn:temp-placeholder-element"
    xmlns:func="urn:temp-functions-defined-in-here"
    expand-text="yes"
    version="3.0">

<xsl:output method="xml" indent="yes"/>

<xsl:namespace-alias stylesheet-prefix="t" result-prefix="xsl"/>

<xsl:variable name="AUTOGENERATED_PREFIX">autogenerated-id-</xsl:variable>

<xsl:template match="/">
    <xsl:comment>This file is autogenerated. DO NOT EDIT.</xsl:comment>
    <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="r:root">
    <t:transform expand-text="yes" version="3.0" exclude-result-prefixes="#all"> <!-- "h r xs fn temp func inject" -->
        <t:output method="xhtml" html-version="5"/>
        <t:mode use-accumulators="#all"/>
        <t:key name="link-target" match="*" use="@id"/>
        <t:key name="internal-id" match="*" use="@temp:id"/>
        <t:key name="internal-parent" match="*" use="@temp:parent"/>
        <t:key name="link-source" match="h:a" use="@href"/>

        <xsl:comment>
            ===============================
            Explanation of the modes; they run in order:
            INITIALIZE_MODE: adds a unique @temp:id and @temp:parent to each element to support  r:link to="child"
            ANNOTATE_MODE: adds a unique @temp:replace-id to each element that is matched because the element may move so the selector will no longer apply
                (maybe this can be combined with INITIALIZE_MODE)
            EXPAND_MODE: replaces the current element with the elements defined in r:replace but does not evaluate any of the dump-counter or dump-bucket.
            MOVE_MODE: dumps the elements in the buckets out so they are now in the content
            NUMBER_MODE: dumps the counters out (which result in things being counted) and stores the target link text for an element (e.g. "Figure 4.3")
            LINK_MODE: populates links with autogenerated text based on what the target is
            ENSURE_ID_MODE: ensures that all elements have an id (especially for the lnik targets)
            ERASE_ID_MODE: removes any autogenerated ids that are not link targets           
            CLEANUP_MODE: remove temporary attributes on elements
            ===============================/
        </xsl:comment>
        <t:template match="/">
            <t:variable name="pipe"><t:apply-templates mode="INITIALIZE_MODE" select="@*|node()"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="ANNOTATE_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="ENSURE_ID_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="EXPAND_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="MOVE_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="NUMBER_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="LINK_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="ERASE_ID_MODE" select="$pipe"/></t:variable>
            <t:variable name="pipe"><t:apply-templates mode="CLEANUP_MODE" select="$pipe"/></t:variable>
            <t:sequence select="$pipe"/>
        </t:template>

        <xsl:apply-templates mode="ACCUMULATORS_MODE" select="//r:bucket"/>
        <xsl:apply-templates mode="ACCUMULATORS_MODE" select="//r:counter"/>

        <!-- Recurse -->
        <xsl:apply-templates select="node()"/>

        <xsl:comment>Preserve the tree hierarchy before things start to move around</xsl:comment>
        <t:template mode="INITIALIZE_MODE" match="*">
            <t:copy inherit-namespaces="no">
                <t:attribute name="temp:id" select="generate-id()"/>
                <t:attribute name="temp:parent" select="generate-id(..)"/>
                <t:apply-templates mode="INITIALIZE_MODE" select="@*|node()"/>
            </t:copy>
        </t:template>

        <xsl:comment>Identity Transform</xsl:comment>
        <t:template match="@*|node()"><t:copy><t:apply-templates select="@*|node()"/></t:copy></t:template>
        <t:template mode="INITIALIZE_MODE" match="@*|node()[not(self::*)]"><t:copy><t:apply-templates mode="INITIALIZE_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="ANNOTATE_MODE" match="@*|node()"><t:copy><t:apply-templates mode="ANNOTATE_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="ENSURE_ID_MODE" match="@*|node()"><t:copy><t:apply-templates mode="ENSURE_ID_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="EXPAND_MODE" match="@*|node()"><t:copy><t:apply-templates mode="EXPAND_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="MOVE_MODE" match="@*|node()"><t:copy><t:apply-templates mode="MOVE_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="NUMBER_MODE" match="@*|node()"><t:copy><t:apply-templates mode="NUMBER_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="LINK_MODE" match="@*|node()"><t:copy><t:apply-templates mode="LINK_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="ERASE_ID_MODE" match="@*|node()"><t:copy><t:apply-templates mode="ERASE_ID_MODE" select="@*|node()"/></t:copy></t:template>
        <t:template mode="CLEANUP_MODE" match="@*|node()"><t:copy><t:apply-templates mode="CLEANUP_MODE" select="@*|node()"/></t:copy></t:template>

        <!-- Remove temporary attributes -->
        <t:template mode="CLEANUP_MODE" match="@temp:replace-id | @temp:id | @temp:parent | @temp:linktext"/>

        <!-- boilerplate -->
        <t:template mode="NUMBER_MODE" match="r:dump-counter">
            <t:value-of select="accumulator-after(@name)"/>
        </t:template>

        <!-- When linking internally look up the link-text of the target element -->
        <t:template mode="LINK_MODE" match="h:a[starts-with(@href, '#')]">
            <t:variable name="targetId" select="substring-after(@href, '#')"/>
            <t:variable name="target" select="key('link-target', $targetId)"/>
            <t:variable name="newText">
                <t:choose>
                    <t:when test="string-length($target[1]/@temp:linktext) > 0">
                        <t:value-of select="$target[1]/@temp:linktext"/>
                    </t:when>
                    <t:when test="not($target)">
                        <t:message terminate="yes">BUG: Could not find link target with id="{{$targetId}}". Maybe it was removed?</t:message>
                    </t:when>
                    <t:otherwise>
                        <t:sequence select="node()"/>
                        [[could not find autogenerate text]]
                    </t:otherwise>
                </t:choose>
            </t:variable>
            <t:copy inherit-namespaces="no">
                <t:apply-templates mode="LINK_MODE" select="@*"/>
                <t:sequence select="$newText"/>
            </t:copy>
        </t:template>

        <t:template mode="LINK_MODE" match="r:link[@to='parent']">
            <t:variable name="parentId" select="ancestor::*[@temp:parent][1]/@temp:parent"/>
            <t:if test="not($parentId)">
                <t:message terminate="yes">BUG: Could not find an ancestor of this link that has a @temp:parent assigned</t:message>
            </t:if>
            <t:variable name="parent" select="key('internal-id', $parentId)"/>
            <t:if test="not($parent)">
                <t:message terminate="yes">BUG: Could not find parent element with temp:id="{{$parentId}}"</t:message>
            </t:if>
            <t:if test="not($parent[1]/@id)">
                <t:message terminate="yes">BUG: This parent element does not have an id attribute on it yet. {@selector}</t:message>
            </t:if>
            <h:a href="#{{$parent[1]/@id}}">
                <t:if test="not($parent/@temp:linktext)">
                    <t:message terminate="yes">Link target #{{$parent[1]/@id}} did not have a link-text element defined for it so do not know how to render the link</t:message>
                </t:if>
                <t:value-of select="$parent[1]/@temp:linktext"/>
            </h:a>
        </t:template>

        <xsl:for-each select=".//r:link[@to='child']">

            <t:template mode="LINK_MODE" match="r:link[@to='child'][@temp:child-link-key='{replace(@selector, &quot;'&quot;, '#')}']">
                <t:variable name="children" select="key('internal-parent', ancestor::*[@temp:id][1]/@temp:id)"/>
                <t:variable name="child" select="$children[self::{@selector}]"/>
                <t:if test="not($child[1]/@id)">
                    <t:message>{{count($child)}} elements out of {{count($children)}} children total</t:message>
                    <t:message terminate="yes">This child element does not have an id attribute on it yet. {@selector} <t:copy-of select="."/></t:message>
                </t:if>
                <h:a href="#{{$child[1]/@id}}">
                    <t:choose>
                        <t:when test="node()">
                            <t:apply-templates mode="LINK_MODE" select="node()"/>
                        </t:when>
                        <t:otherwise>
                            <t:if test="not($child/@temp:linktext)">
                                <t:message terminate="no">Link target #{{$child[1]/@id}} did not have a link-text element defined for it so do not know how to render the link</t:message>
                            </t:if>
                            <t:value-of select="$child[1]/@temp:linktext"/>
                        </t:otherwise>
                    </t:choose>
                </h:a>
            </t:template>

        </xsl:for-each>

        <t:template mode="ENSURE_ID_MODE" match="*[not(@id)]">
            <t:copy inherit-namespaces="no">
                <t:attribute name="id">{$AUTOGENERATED_PREFIX}{{generate-id(.)}}</t:attribute>
                <t:apply-templates mode="ENSURE_ID_MODE" select="@*|node()"/>
            </t:copy>
        </t:template>

        <t:template mode="ERASE_ID_MODE" match="@id[starts-with(., '{$AUTOGENERATED_PREFIX}')]">
            <t:variable name="href">#{{.}}</t:variable>
            <t:variable name="linkSource" select="key('link-source', $href)"/>
            <t:if test="not(empty($linkSource))">
                <t:copy/>
            </t:if>
            <!-- Otherwise, discard the attribute since no one links to it -->
        </t:template>

        <!-- The children of this node are matches explicitly -->
        <t:template mode="NUMBER_MODE" match="r:link-text"/>

        <!-- Do not copy comments into the link text. The comment will just show up as plain text in the link which is weird -->
        <t:template mode="NUMBER_MODE" match="r:link-text//comment()"/>

        <xsl:apply-templates mode="DECLARE_DUMPSITES" select=".//r:dump-bucket"/>
        <xsl:apply-templates mode="DECLARE_DUMPSITES" select=".//r:copy-content"/>

        <t:template mode="INITIALIZE_MODE" match="h:head[not(h:style)]">
            <t:copy>
                <t:apply-templates mode="INITIALIZE_MODE" select="@*|node()"/>
                <style>
                    /* Debug-styling-to-make-it-easier-to-inspect */
                    :target {{{{ background-color: #ffc; }}}}
/*
                    section, div, p[data-type="solution"] {{{{
                        border: 1px dotted #ccc;
                        margin: 1rem;
                    }}}}
*/
                </style>
                <link rel="stylesheet" href="stylesheet-pdf.css"/>
            </t:copy>
        </t:template>

        <!-- FIXME: instead of using a separate namespace, clobber the HTML namespace with "inject-" elements and attributes
             For some reason the the namespace declaration remained on elements even though it was explicitly excluded
             and nothing in it still had the namespace -->
        <t:template mode="ERASE_ID_MODE" match="h:inject-element">
            <t:element name="{{@inject-name}}" namespace="http://www.w3.org/1999/xhtml" inherit-namespaces="no">
                <t:apply-templates mode="ERASE_ID_MODE" select="@*|node()"/>
            </t:element>
        </t:template>

        <t:template mode="ERASE_ID_MODE" match="h:inject-element/@*">
            <t:choose>
                <t:when test="local-name() = 'inject-name'"/>
                <t:when test="starts-with(local-name(), 'inject-')">
                    <t:attribute name="{{substring-after(local-name(), 'inject-')}}">{{.}}</t:attribute>
                </t:when>
                <t:otherwise>
                    <t:message terminate="no">BUG? Injected element has a non-injected attribute</t:message>
                    <t:copy/>
                </t:otherwise>
            </t:choose>
        </t:template>


        <t:function name="temp:getId" as="xs:string">
            <t:param name="context" as="element()"/>
            <t:choose>
                <t:when test="$context/@id">
                    <t:value-of select="$context/@id"/>
                </t:when>
                <t:otherwise>
                    <t:message terminate="yes">BUG: Found an element that does not have an id attribute. {{local-name($context)}} data-type={{$context/@data-type}}</t:message>
                </t:otherwise>
            </t:choose>
        </t:function>

        <t:function name="func:hasClass" as="xs:boolean">
            <t:param name="class" as="xs:string?"/>
            <t:param name="className" as="xs:string"/>
            <t:choose>
                <t:when test="empty($class)">{true()}</t:when>
                <t:otherwise>
                    <t:sequence select="fn:exists(fn:index-of(fn:tokenize($class, '\s+'), $className))"/>
                </t:otherwise>
            </t:choose>
        </t:function>

        <!-- <t:function name="temp:addClass" as="xs:string">
            <t:param name="class" as="xs:string"/>
            <t:param name="className" as="xs:string"/>
            <t:value-of select="fn:normalize-space(fn:concat($class, ' ', $className))"/>
        </t:function> -->

    </t:transform>
</xsl:template>

<xsl:template match="r:replace">
    <xsl:variable name="matchString">
        <xsl:call-template name="build-match-with-self"/>
    </xsl:variable>
    <xsl:variable name="variablesDefined" select="r:count-value/@name"/>
    <xsl:variable name="variablesUsed" select="distinct-values(.//r:dump-counter/@name)"/>
    <xsl:variable name="templateId" select="generate-id()"/>
    <xsl:variable name="classMatchString">*[@temp:replace-id = '{$templateId}']</xsl:variable>

    <t:template mode="ANNOTATE_MODE" match="{$matchString}">
        <t:copy inherit-namespaces="no">
            <t:if test="@temp:replace-id">
                <t:message>This element was already matched by a different selector @temp:replace-id={{@temp:replace-id}}</t:message>
            </t:if>
            <t:attribute name="temp:replace-id">{$templateId}</t:attribute>
            <t:apply-templates mode="ANNOTATE_MODE" select="@*|node()"/>
        </t:copy>
    </t:template>

    <xsl:comment>@temp:replace-id='{$templateId}' is actually: {$matchString}</xsl:comment>
    <t:template mode="EXPAND_MODE" match="{$classMatchString}">
        <xsl:apply-templates select="node()[not(self::r:replace)]">
            <xsl:with-param tunnel="yes" name="currentMode">EXPAND_MODE</xsl:with-param>
            <xsl:with-param tunnel="yes" name="variablesDefined" select="$variablesDefined"/>
            <xsl:with-param tunnel="yes" name="variablesUsed" select="$variablesUsed"/>
        </xsl:apply-templates>
    </t:template>

    <xsl:choose>
        <xsl:when test="@move-to">
            <t:template mode="MOVE_MODE" match="{$matchString}">
                <t:comment>Moved "{$matchString}" because it had a @move-to</t:comment>
                <t:message>Removing element {$matchString} because it has a @move-to</t:message>
            </t:template>
        </xsl:when>
        <xsl:otherwise>
            <t:template mode="MOVE_MODE" match="{$matchString}">
                <t:copy>
                    <t:apply-templates mode="MOVE_MODE" select="@*|node()">
                        <t:with-param tunnel="yes" name="nearestReplacerContext" select="."/>
                    </t:apply-templates>
                </t:copy>
            </t:template>
        </xsl:otherwise>
    </xsl:choose>

    <t:template mode="NUMBER_MODE" match="{$classMatchString}">
        <xsl:for-each select="$variablesUsed">
            <t:param tunnel="yes" name="{.}"/>
        </xsl:for-each>
        <xsl:apply-templates select="r:count-value"/>
        <t:copy>
            <t:apply-templates mode="NUMBER_MODE" select="@*"/>
            <t:if test="r:link-text/node()">
                <t:variable name="linktextValue">
                    <t:apply-templates mode="NUMBER_MODE" select="r:link-text/node()">
                        <t:with-param tunnel="yes" name="nearestReplacerContext" select="."/>
                    </t:apply-templates>
                </t:variable>
                <t:if test="not(string-length($linktextValue) > 0)">
                    <t:message terminate="yes">Computed link text for element is empty. The nodes were: [<t:copy-of select="r:link-text"/>]</t:message>
                </t:if>
                <t:attribute name="temp:linktext">{{$linktextValue}}</t:attribute>
            </t:if>
            <xsl:call-template name="applyAllChildren">
                <xsl:with-param tunnel="yes" name="currentMode">NUMBER_MODE</xsl:with-param>
                <xsl:with-param tunnel="yes" name="variablesDefined" select="$variablesDefined"/>
                <xsl:with-param tunnel="yes" name="variablesUsed" select="$variablesUsed"/>
            </xsl:call-template>
        </t:copy>
    </t:template>

    <xsl:apply-templates select="r:replace">
        <xsl:with-param tunnel="yes" name="variablesDefined" select="$variablesDefined"/>
        <xsl:with-param tunnel="yes" name="variablesUsed" select="$variablesUsed"/>
    </xsl:apply-templates>
</xsl:template>


<xsl:template match="r:this">
    <xsl:comment>r:this</xsl:comment>
    <t:copy>
        <xsl:apply-templates select="@*"/>
        <t:apply-templates select="@*"/>

        <xsl:if test="ancestor::r:replace[1]/r:declare/r:link-text">
            <r:link-text>
                <xsl:apply-templates select="ancestor::r:replace[1]/r:declare/r:link-text/node()"/>
            </r:link-text>
        </xsl:if>
        <xsl:apply-templates select="node()"/>
    </t:copy>
</xsl:template>

<!-- Create the attributes on the resulting "this" -->
<xsl:template match="r:this/@h:*">
    <t:attribute name="{local-name()}">{.}</t:attribute>
</xsl:template>


<xsl:template match="r:children" name="applyAllChildren">
    <xsl:param tunnel="yes" name="currentMode" as="xs:string"/>
    <xsl:param tunnel="yes" name="variablesDefined"/>
    <xsl:comment>r:children selector="{@selector}"</xsl:comment>
    <t:apply-templates mode="{$currentMode}" select="node()">
        <xsl:for-each select="$variablesDefined">
            <t:with-param tunnel="yes" name="{.}" select="${.}"/>
        </xsl:for-each>
    </t:apply-templates>
</xsl:template>

<xsl:template match="r:children[@selector]">
    <xsl:param tunnel="yes" name="currentMode" as="xs:string"/>
    <xsl:param tunnel="yes" name="variablesDefined"/>
    <xsl:comment>r:children selector="{@selector}"</xsl:comment>
    <t:apply-templates mode="{$currentMode}" select="{@selector}">
        <xsl:for-each select="$variablesDefined">
            <t:with-param tunnel="yes" name="{.}" select="${.}"/>
        </xsl:for-each>
    </t:apply-templates>
</xsl:template>


<xsl:template match="r:link-text"/>

<xsl:template match="r:copy-content">
    <xsl:variable name="id" select="generate-id()"/>
    <xsl:copy>
        <xsl:attribute name="temp:id">COPY_CONTENT_{@name}_{$id}</xsl:attribute>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>
<xsl:template mode="DECLARE_DUMPSITES" match="r:copy-content">
    <xsl:variable name="id" select="generate-id()"/>
    <t:template mode="NUMBER_MODE" match="r:copy-content[@temp:id='COPY_CONTENT_{@name}_{$id}']">
        <t:param tunnel="yes" name="nearestReplacerContext" as="element()"/>
        <t:variable name="nodesToCopy" select="$nearestReplacerContext/{@selector}"/>
        <t:if test="empty($nodesToCopy)">
            <t:message terminate="yes">ERROR: Could not find anything to copy when selecting "{@selector}". inside r:copy-content for 'COPY_CONTENT_{@name}_{$id}'. nearestReplacerContext is a @data-type="{{$nearestReplacerContext/@data-type}}" id="{{$nearestReplacerContext/@id}}" class="{{$nearestReplacerContext/@class}}".</t:message>
        </t:if>
        <t:apply-templates mode="NUMBER_MODE" select="$nearestReplacerContext/{@selector}"/>
    </t:template>
</xsl:template>

<xsl:template match="r:dump-bucket">
    <xsl:variable name="id" select="generate-id()"/>
    <xsl:copy>
        <xsl:attribute name="temp:id">DUMP_BUCKET_{@name}_{$id}</xsl:attribute>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<xsl:template mode="DECLARE_DUMPSITES" match="r:dump-bucket[not(@group-by)]">
    <xsl:variable name="id" select="generate-id()"/>
    <t:template mode="MOVE_MODE" match="r:dump-bucket[@temp:id='DUMP_BUCKET_{@name}_{$id}']">
        <t:comment> r:dump-bucket[@name='{@name}'][not(@group-by)] DUMP_BUCKET_{@name}_{$id}</t:comment>
        <t:for-each select="accumulator-after('{@name}')">
            <!-- Ensure that the element is actually copied (not removed because it was moved). 
                    But ensure that the children are removed if they were also moved -->
            <t:copy>
                <t:apply-templates mode="MOVE_MODE" select="@*|node()"/>
            </t:copy>
        </t:for-each>
    </t:template>
</xsl:template>

<xsl:template mode="DECLARE_DUMPSITES" match="r:dump-bucket[@group-by]">
    <xsl:variable name="id" select="generate-id()"/>
    <t:template mode="MOVE_MODE" match="r:dump-bucket[@temp:id='DUMP_BUCKET_{@name}_{$id}']">
        <t:param tunnel="yes" name="nearestReplacerContext" as="element()"/>
        <t:variable name="groups" select="$nearestReplacerContext/{@group-by}"/>
        <t:comment> DUMP_BUCKET_{@name}_{$id} . Found {{count($groups)}} groups to loop over</t:comment>
        <t:comment>nearestReplacerContext is a {{local-name($nearestReplacerContext)}} with data-type={{$nearestReplacerContext/@data-type}}</t:comment>
        <t:for-each select="$nearestReplacerContext/{@group-by}">
            <t:variable name="groupEl" select="."/>
            <t:variable name="title" select="{@group-by-title}"/>
            <t:variable name="items">
                <!-- filter the items to be the ones in the group -->
                <t:for-each select="accumulator-after('{@name}')">
                    <t:variable name="nearestGroupEl" select="ancestor::{@group-by}"/>
                    <t:if test="$groupEl[1] = $nearestGroupEl[1]">
                        <!-- Ensure that the element is actually copied (not removed because it was moved). 
                            But ensure that the children are removed if they were also moved -->
                        <t:copy>
                            <t:apply-templates mode="MOVE_MODE" select="@*|node()"/>
                        </t:copy>
                    </t:if>
                </t:for-each>
            </t:variable>
            <t:choose>
                <t:when test="not(empty($items/*))">
                    <h:div class="-i-am-a-group-by-block">
                        <h:h3><h:a href="#{{temp:getId($groupEl)}}">[this-will-be-replaced-with-autogen-linktext]</h:a></h:h3>
                        <t:sequence select="$items"/>
                    </h:div>
                </t:when>
                <t:otherwise>
                    <t:comment>Skipping group because no items matched</t:comment>
                </t:otherwise>
            </t:choose>
        </t:for-each>
    </t:template>
</xsl:template>

<xsl:template match="r:chapter-outline">
    <h:div class="os-chapter-outline">
        <h:div class="os-title">{@name}</h:div>

        <t:for-each select="../*[@data-type='page']">
            <h:div class="os-chapter-objective">
                <h:a href="#{{temp:getId(.)}}">[this-will-be-replaced-with-autogen-linktext]</h:a>
            </h:div>
        </t:for-each>
    </h:div>
</xsl:template>

<!--We have to hardcode the selector because XSLT Home Edition does not support dynamic selectors-->
<xsl:template match="r:link[@to='child']/@selector">
    <xsl:attribute name="temp:child-link-key" select="replace(., &quot;'&quot;, '#')"/>
</xsl:template>

<xsl:template mode="ACCUMULATORS_MODE" match="r:bucket">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="resetMatchString">
        <xsl:call-template name="build-match-ancestors"/>
    </xsl:variable>
    <t:accumulator name="{@name}" initial-value="()">
        <t:accumulator-rule match="{$resetMatchString}" select="()"/>
        <xsl:for-each select="/r:root//r:replace[@move-to=$name]">
            <xsl:variable name="appendMatchString">
                <xsl:call-template name="build-match-with-self"/>
            </xsl:variable>
            <t:accumulator-rule match="{$appendMatchString}" select="$value union ."/>
        </xsl:for-each>
    </t:accumulator>
</xsl:template>

<xsl:template mode="ACCUMULATORS_MODE" match="r:counter">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="startAt" select="@start-at" as="xs:integer"/>
    <xsl:variable name="resetMatchString">
        <xsl:call-template name="build-match-ancestors"/>
    </xsl:variable>
    <t:accumulator name="{@name}" initial-value="0">
        <t:accumulator-rule match="{$resetMatchString}" select="{$startAt - 1}"/>
        <t:accumulator-rule match="{@selector}" select="$value + 1"/>
    </t:accumulator>
</xsl:template>

<!-- Discard the declaration block. We no longer need it -->
<xsl:template match="r:declare"/>

<xsl:template name="build-match-with-self"><xsl:for-each select="ancestor::r:replace">/{@selector}<xsl:if test="@class">[@class][func:hasClass(@class, '{@class}')]</xsl:if></xsl:for-each><xsl:if test="@selector">/{@selector}</xsl:if><xsl:if test="@class">[@class][func:hasClass(@class, '{@class}')]</xsl:if></xsl:template>
<xsl:template name="build-match-ancestors"><xsl:for-each select="ancestor::r:replace">/{@selector}<xsl:if test="@class">[@class][func:hasClass(@class, '{@class}')]</xsl:if></xsl:for-each></xsl:template>

<!--Change the namespace of injected elements so that we do not accidentally match on them
    This occurred when we injected new pages into a chapter. We unexpectedly began matching on them
    -->
<xsl:template match="h:*">
    <inject-element inject-name="{local-name()}">
        <xsl:apply-templates select="@*|node()"/>
    </inject-element>
</xsl:template>

<xsl:template match="h:*/@*">
    <xsl:attribute name="inject-{local-name()}">{.}</xsl:attribute>
</xsl:template>


<!-- Identity Transform -->
<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>