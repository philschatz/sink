<!--

Helpful references:

XSLT3.0: https://www.w3.org/TR/xslt-30/
XPath functions: https://www.w3.org/TR/xpath-functions-30/

-->

<xsl:transform
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="urn:recipe-config-xml"
    xmlns:r="urn:replacer-xml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="g"
    expand-text="yes"
    version="3.0">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
    <xsl:comment>This file is autogenerated. DO NOT EDIT.</xsl:comment>
    <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="g:root">
    <r:root>
        <r:replace selector="h:html/h:body">
            <r:declare>
                <r:bucket name="solutionBucket"/>
                <r:counter start-at="1" name="chapterCounter" selector="*[@data-type='chapter']"/>
            </r:declare>

            <r:this>
                <r:children/>

                <xsl:apply-templates select="g:book-page-solutions | g:book-page | g:index"/>
            </r:this>

            <!--Chapter-->
            <r:replace selector="*[@data-type='chapter']">
                <r:declare>
                    <r:link-text>Chapter <r:dump-counter name="chapterCounter"/></r:link-text>
                    <r:counter start-at="0" name="sectionCounter" selector="*[@data-type='page']"/>
                    <r:counter start-at="1" name="exerciseCounter" selector="*[@data-type='exercise']"/>
                    <r:counter start-at="1" name="figureCounter" selector="h:figure"/>
                    <r:counter start-at="1" name="tableCounter" selector="h:table"/>

                    <xsl:for-each select="g:chapter-page">
                        <r:bucket name="iamapagebucket-{@class}"/>
                    </xsl:for-each>
                    <xsl:if test="g:chapter-glossary">
                        <r:bucket name="iamaglossarypagebucket"/>
                    </xsl:if>
                </r:declare>

                <r:this>
                    <r:children/>
                    <xsl:apply-templates select="g:chapter-page | g:chapter-glossary"/>
                </r:this>

                <r:replace selector="*[@data-type='document-title']">
                    <r:this>
                        <span class="os-number">Chapter <r:dump-counter name="chapterCounter"/></span>
                        <span class="os-divider"> </span>
                        <span class="os-text"><r:children/></span>
                    </r:this>
                </r:replace>

                <xsl:for-each select="g:chapter-page">
                    <r:replace move-to="iamapagebucket-{@class}" selector="/*[@class='{@class}']">
                        <xsl:comment>TODO: BUG: Unwrap the section and remove the title</xsl:comment>
                        <r:this h:data-todo="UNWRAPME">
                            <r:children selector="node()[not(self::*[@data-type='title'])]"/>
                        </r:this>
                    </r:replace>
                </xsl:for-each>

                <xsl:if test="g:chapter-glossary">
                    <r:replace move-to="iamaglossarypagebucket" selector="/*[@data-type='glossary']">
                        <xsl:comment>TODO: BUG: Unwrap the section and remove the title</xsl:comment>
                        <r:this h:data-todo="UNWRAPME">
                            <r:children selector="node()[not(self::*[@data-type='glossary-title'])]"/>
                        </r:this>
                    </r:replace>
                </xsl:if>

                <!--Exercise that has a solution-->
                <r:replace selector="/*[@data-type='exercise'][*[@data-type='solution']]">
                    <r:declare>
                        <r:link-text>
                            <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="exerciseCounter"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <r:link to="child" selector="*[@data-type='solution']"><r:dump-counter name="exerciseCounter"/></r:link>
                        <r:children/>
                    </r:this>

                    <!--Solution-->
                    <r:replace move-to="solutionBucket" selector="*[@data-type='solution']">
                        <r:this>
                            <r:link to="parent"/>
                            <r:children/>
                        </r:this>
                    </r:replace>
                </r:replace>

                <!--Exercise with no solution-->
                <r:replace selector="/*[@data-type='exercise'][not(*[@data-type='solution'])]">
                    <r:declare>
                        <r:link-text>
                            <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="exerciseCounter"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <strong>
                            <r:dump-counter name="exerciseCounter"/>
                        </strong>
                        <r:children/>
                    </r:this>
                </r:replace>

                <!--Table-->
                <r:replace selector="/h:table">
                    <xsl:apply-templates select="g:table-caption[@in='ANY_PART' or @in='CHAPTER_PART']"/>
                </r:replace>

                <!--Figure-->
                <r:replace selector="/h:figure">
                    <xsl:apply-templates select="g:figure-caption[@in='ANY_PART' or @in='CHAPTER_PART']"/>
                </r:replace>

                <!--Note-->
                <xsl:apply-templates select="g:note"/>

                <!--Section-->
                <r:replace selector="*[@data-type='page'][not(@class)]">
                    <r:declare>
                        <r:link-text>
                            <!--TODO: Maybe copy-content should somehow squirrel away the original content instead of the expanded content-->
                            <!-- <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="sectionCounter"/>:  -->
                            <r:copy-content selector="*[@data-type='document-title']/node()"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <r:children/>
                    </r:this>

                    <!-- Add the section number to the title -->
                    <r:replace selector="*[@data-type='document-title']">
                        <r:this><!--<h1 data-type="document-title">-->
                            <span class="os-text">
                                <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="sectionCounter"/>: <r:children/>
                            </span>
                        </r:this>
                    </r:replace>
                </r:replace>

                <!-- Introduction (mostly copy/pasta from the non-intro replacer) -->
                <r:replace selector="*[@data-type='page']" class="introduction">
                    <r:declare>
                        <r:link-text>
                            <r:copy-content selector="*[@data-type='document-title']/node()"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <xsl:if test="g:chapter[@outline]">
                            <r:chapter-outline name="{g:chapter/@outline}"/>
                        </xsl:if>
                        <r:children/>
                    </r:this>

                    <r:replace selector="*[@data-type='document-title']">
                        <r:this><!--<h1 data-type="document-title">-->
                            <span class="os-text">
                                <r:children/>
                            </span>
                        </r:this>
                    </r:replace>
                </r:replace>

            </r:replace>

            <!-- Wrap the title with a span for extra styling -->
            <r:replace selector="*[@data-type='page']" class="preface">
                <r:this><r:children/></r:this>

                <r:replace selector="*[@data-type='document-title']">
                    <r:this><!--<h1 data-type="document-title">-->
                        <span class="os-text">
                            <r:children/>
                        </span>
                    </r:this>
                </r:replace>
            </r:replace>

        </r:replace>

    </r:root>
</xsl:template>

<xsl:template match="g:book-page-solutions">
    <div data-type="composite-chapter" data-uuid-key=".{@class}" class="os-eob os-{@class}-container">
        <h1 data-type="document-title">
            <span class="os-text">{@name}</span>
        </h1>
        <r:dump-bucket name="solutionBucket" group-by="*[@data-type='chapter']" group-by-title="./*[@data-type='document-title']"/>
    </div>
</xsl:template>

<xsl:template match="g:chapter-page">
    <div data-type="page" data-uuid-key=".{@class}">
        <h2>{@name}</h2>
        <xsl:choose>
            <xsl:when test="@cluster='YES'">
                <r:dump-bucket name="iamapagebucket-{@class}" group-by="*[@data-type='page']" group-by-title="./*[@data-type='document-title']"/>
            </xsl:when>
            <xsl:otherwise>
                <r:dump-bucket name="iamapagebucket-{@class}"/>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="g:chapter-glossary">
    <div data-type="page" data-uuid-key="glossary">
        <h2>{@name}</h2>
        <r:dump-bucket name="iamaglossarypagebucket"/>
    </div>
</xsl:template>


<xsl:template match="g:table-caption[@placement='BOTTOM']">
    <r:declare>
        <r:link-text>
            <xsl:apply-templates select="node()"/>
        </r:link-text>
    </r:declare>
    <div class="os-table">
        <r:this>
            <r:children selector="node()[not(self::h:caption)]"/>
        </r:this>
        <div class="os-caption-container">
            <xsl:apply-templates select="node()"/>
            <r:children selector="h:caption/node()"/>
        </div>
    </div>
</xsl:template>


<xsl:template match="g:figure-caption[@placement='TOP']">
    <r:declare>
        <r:link-text>
            <xsl:apply-templates select="node()"/>
        </r:link-text>
    </r:declare>
    <div class="os-figure">
        <div class="os-caption-container">
            <r:children selector="h:figcaption"/>
        </div>
        <r:this>
            <r:children selector="node()[not(self::h:figcaption)]"/>
        </r:this>
    </div>
    
    <!--Caption-->
    <r:replace selector="h:figcaption">
        <r:this>
            <strong>
                <xsl:apply-templates select="node()"/>
            </strong>
            <r:children/>
        </r:this>
    </r:replace>
</xsl:template>

<xsl:template match="g:note">
    <r:replace selector="/*[@data-type='note']" class="{@class}">
        <r:this h:class="os-note {@class}"><!--HACK: Should have a way to append the class-->
            <h:h6 data-type="title" class="os-note-title">{@name}</h:h6>
            <h:div class="os-note-body">
                <r:children selector="*[not(@data-type='title')]"/>
            </h:div>
        </r:this>
    </r:replace>
</xsl:template>

<xsl:template match="g:*">
    <xsl:copy-of select="."/>
    <xsl:message terminate="yes">BUG: Did not match this element. Non-exhaustive XSLT</xsl:message>
</xsl:template>

<!-- Identity Transform -->
<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

</xsl:transform>